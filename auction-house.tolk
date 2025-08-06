const MY_WORKCHAIN = BASECHAIN;
const OP_BID = stringCrc32("bid");   // 13f2c12a
const OP_CLOSE = stringCrc32("close"); // 82ab9120

var highestBid: int = 0;
var closed: int = 0;

fun placeBid(amount: int) {
    assert(closed == 0) throw 1006;
    if (amount > highestBid) {
        highestBid = amount;
    }
}

fun closeAuction() {
    closed = 1;
}

fun routeInternal(`ctx::sender`: slice, `ctx::value`: int, `ctx::fwd_fee`: int, `ctx::body`: slice) {
    var (op: int, _) = `ctx::body`.loadOpAndQueryId();

    if (op == OP_BID) {
        placeBid(50);
        return;
    }

    if (op == OP_CLOSE) {
        closeAuction();
        return;
    }

    throw 0xffff;
}

fun main(`ctx::value`: int, inMsgFull: cell, `ctx::body`: slice) {
    var s = inMsgFull.beginParse();
    var flags = s.loadMsgFlags();
    if (isBounced(flags)) { return; }

    var (`ctx::sender`: slice, `ctx::fwd_fee`: int) = s.retrieveCtx(MY_WORKCHAIN);
    routeInternal(`ctx::sender`, `ctx::value`, `ctx::fwd_fee`, `ctx::body`);
}
