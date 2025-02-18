
const utf8Decoder = new TextDecoder();



export type PrintView<T> = {
    [K in keyof T]: T[K] extends Uint8Array ? string : T[K];
};


export function printable<T extends object>(event: T): PrintView<T> {
    return Object.fromEntries(
        Object.entries(event).map(([k, v]) => [k, v instanceof Uint8Array ? utf8Decoder.decode(v) : v])
    ) as PrintView<T>;
}

export function assertAllDefined<T>(values: (T | undefined)[], message: string | (() => string)): T[] {
    values.forEach(value => assertDefined(value, message));
    return values as T[];
}

export function assertDefined<T>(value: T | undefined, message: string | (() => string)): T {
    if (value == undefined) {
        throw new Error(typeof message === 'string' ? message : message());
    }

    return value;
}
