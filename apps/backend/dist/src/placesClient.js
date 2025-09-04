const BASE = "https://places.googleapis.com/v1";
// Google Places API v1 Field Masks
// 
// LIST (searchText) - Response has "places" array, so prefix with "places."
// DETAIL (get place) - Single object, no prefix needed
//
// Self-check: 
// - LIST uses "places.*" prefixes ✓
// - DETAIL uses top-level fields ✓  
// - weekdayDescriptions (not weekdayText) ✓
// - reviews.text.text (nested structure) ✓
const FIELD_MASK_LIST = [
    "places.id",
    "places.displayName",
    "places.rating",
    "places.userRatingCount",
    "places.formattedAddress",
    "places.location",
    "places.primaryType",
    "places.types",
    "places.photos.name",
    "places.editorialSummary",
    "places.businessStatus",
    "places.priceLevel"
].join(",");
const FIELD_MASK_DETAIL = [
    "id",
    "displayName",
    "formattedAddress",
    "location",
    "websiteUri",
    "internationalPhoneNumber",
    "nationalPhoneNumber",
    "rating",
    "userRatingCount",
    "businessStatus",
    "types",
    "priceLevel",
    "editorialSummary",
    "photos.name",
    "regularOpeningHours.weekdayDescriptions",
    "currentOpeningHours.weekdayDescriptions",
    "reviews.rating",
    "reviews.publishTime",
    "reviews.authorAttribution.displayName",
    "reviews.authorAttribution.uri",
    "reviews.authorAttribution.photoUri",
    "reviews.text.text",
    "reviews.relativePublishTimeDescription"
].join(",");
export async function textSearch(query, lat, lng) {
    const key = process.env.GOOGLE_PLACES_BACKEND_KEY;
    const body = { textQuery: query, languageCode: "ko", regionCode: "KR" };
    if (lat && lng) {
        body.locationBias = { circle: { center: { latitude: lat, longitude: lng }, radius: 5000 } };
    }
    const res = await fetch(`${BASE}/places:searchText`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": key,
            "X-Goog-FieldMask": FIELD_MASK_LIST,
            "Accept-Language": "ko",
        },
        body: JSON.stringify(body),
    });
    if (!res.ok)
        throw new Error(`textSearch failed: ${res.status} ${await res.text()}`);
    return res.json();
}
export async function placeDetail(placeId) {
    const key = process.env.GOOGLE_PLACES_BACKEND_KEY;
    if (!key)
        throw new Error("GOOGLE_PLACES_BACKEND_KEY missing");
    // Ensure path like /v1/places/{PLACE_ID}
    // Do NOT encode the slash; encode ONLY the id segment.
    const idOnly = placeId.replace(/^places\//, "");
    const url = `${BASE}/places/${encodeURIComponent(idOnly)}?languageCode=ko&regionCode=KR`;
    console.log("🔍 Google Places API URL:", url);
    console.log("🔍 Field Mask:", FIELD_MASK_DETAIL);
    const res = await fetch(url, {
        headers: {
            "X-Goog-Api-Key": key,
            "X-Goog-FieldMask": FIELD_MASK_DETAIL,
            "Accept-Language": "ko",
        },
    });
    if (!res.ok) {
        const body = await res.text();
        console.error("❌ Google Places API Error:", res.status, body);
        throw new Error(`UPSTREAM_${res.status}: ${body}`);
    }
    const data = await res.json();
    console.log("✅ Google Places API Success for:", placeId);
    return data;
}
// Google Places API v1에서는 리뷰를 별도로 가져올 수 없습니다.
// 기본적으로 최대 5개의 리뷰만 반환됩니다.
// 더 많은 리뷰를 원한다면 Google Places API v3을 사용하거나
// 다른 방법을 고려해야 합니다.
export function scorePlace(p) {
    const r = Number(p.rating ?? 0);
    const n = Number(p.userRatingCount ?? 0);
    return r * Math.log(1 + n);
}
export async function placePhoto(placeId, photoResourceName, maxWidthPx = 1200) {
    const key = process.env.GOOGLE_PLACES_BACKEND_KEY;
    // photoResourceName가 'places/..../photos/....' 전체 경로로 올 경우 그대로 사용
    const name = photoResourceName.startsWith('places/')
        ? photoResourceName
        : `places/${encodeURIComponent(placeId)}/photos/${encodeURIComponent(photoResourceName)}`;
    const url = `${BASE}/${name}/media?maxWidthPx=${maxWidthPx}`;
    const res = await fetch(url, { headers: { "X-Goog-Api-Key": key, Accept: "image/*" } });
    if (!res.ok)
        throw new Error(`photo failed: ${res.status} ${await res.text()}`);
    const arrayBuf = await res.arrayBuffer();
    const contentType = res.headers.get("content-type") || "image/jpeg";
    return { arrayBuf, contentType };
}
