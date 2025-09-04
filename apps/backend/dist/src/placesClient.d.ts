export declare function textSearch(query: string, lat?: number, lng?: number): Promise<unknown>;
export declare function placeDetail(placeId: string): Promise<unknown>;
export declare function scorePlace(p: any): number;
export declare function placePhoto(placeId: string, photoResourceName: string, maxWidthPx?: number): Promise<{
    arrayBuf: ArrayBuffer;
    contentType: string;
}>;
//# sourceMappingURL=placesClient.d.ts.map