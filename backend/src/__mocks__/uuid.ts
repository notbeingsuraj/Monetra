let count = 0;
export const v4 = jest.fn(() => `12345678-1234-1234-1234-${String(count++).padStart(12, '0')}`);
