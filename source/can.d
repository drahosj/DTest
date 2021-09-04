module can;

import rt.stdc;

import Core.Inc.can;
import Core.Inc.hal;

void transmit(const(char)[] message, uint stdId)
{
    CAN_TxHeaderTypeDef txh;
    
    assert(stdId <= 0x3ff, "ID doesn't fit in 12 bits");
    
    txh.StdId = stdId;
    txh.IDE = CAN_ID_STD;
    txh.RTR = CAN_RTR_DATA;
    txh.DLC = message.length;
    txh.TransmitGlobalTime = FunctionalState.DISABLE;
    
    uint mbox;
    
    
    static assert(char.sizeof == ubyte.sizeof, "CHAR AND UBYTE ARE NOT THE SAME, EXPLODE!");
    auto status = HAL_CAN_AddTxMessage(&hcan1, &txh, cast(ubyte *) message.ptr, &mbox);
    printf("Status: %d\n", status);
    
    
    while (HAL_CAN_IsTxMessagePending(&hcan1, mbox)) { }
    printf("No longer pending.\n");
    
    printf("ESR: %08lx\n", hcan1.Instance.ESR);
    printf("TSR: %08lx\n", hcan1.Instance.TSR);
}

void test()
{
    string[8] messages = [
        "a",
        "bc",
        "def",
        "ghij",
        "klmno",
        "pqrstu",
        "vwxyzAB",
        "vwxyzABC"
    ];
    
    for (int i = 0; i < 10; i++) {
        foreach(m; messages) {
            transmit(m, 100 * i);
        }
    }
}
