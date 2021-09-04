module rt.syscalls;

import Core.Inc.hal;
import Core.Inc.usart;


void io_putchar(int c)
{
	while (!LL_USART_IsActiveFlag_TXE(USART2)) {}
	LL_USART_TransmitData8(USART2, cast(ubyte) c);
}

extern (C) int _write(int file, char *ptr, int len)
{
	int DataIdx;

	for (DataIdx = 0; DataIdx < len; DataIdx++)
	{
		io_putchar(*ptr++);
	}
	return len;
}
