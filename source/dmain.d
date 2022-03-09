module dmain;

import rt.stdc;
import rt.refcount;

import Core.Inc.main;
/* Hack needed because ST forgot to include this in the generated main.h */
extern (C) void SystemClock_Config();

import Core.Inc.gpio;
import Core.Inc.usart;
import Core.Inc.can;

import Core.Inc.hal;

static import can = dcan;

extern (C) void main()
{
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();
    MX_USART2_UART_Init();
    MX_CAN1_Init();
    
    printf("Hello, world\n");
    int[6] delays = [25, 25, 10, 10, 5, 15];
    foreach(d; delays) {
        HAL_GPIO_TogglePin(LD2_GPIO_Port, LD2_Pin);
        HAL_Delay(d);
    }
    
    
    printf("Starting CAN\n");
    HAL_CAN_Start(&hcan1);
    
    printf("Transmitting CAN\n");
    
    /* Create a dynamic array because we can */
    RefCountedArray!(can.CanMessage) canMessages;
    canMessages = RefCountedArray!(can.CanMessage)(16);
    
    for (int i=0; i < 8; i++) {
        canMessages[i] = can.CanMessage("1half", 100);
    }
    for (int i=8; i < 16; i++) {
        canMessages[i] = can.CanMessage("2half", 100);
    }
    
    
    HAL_Delay(100);
    can.test();
    HAL_Delay(100);
    
    printf("Sending first half messages\n");
    can.transmitMessages(canMessages.array[0..8]);
    can.transmitMessages(canMessages.array[8..$]);
    printf("Done with CAN\n");
    while(true) {}
}
