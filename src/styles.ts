// logo-gen ToothKind 18안(2026-09-15)의 스타일 지시를 대상과 분리해 일반화했다.
// 원본은 logo-gen/public/toothkind-styles/manifest.json.
export type StyleGroup =
  "입체·재질" | "그래픽·캐릭터" | "회화·인쇄" | "간결·장식";
export type AssetStyle = {
  id: string;
  label: string;
  group: StyleGroup;
  treatment: string;
};

export const groups: StyleGroup[] = [
  "입체·재질",
  "그래픽·캐릭터",
  "회화·인쇄",
  "간결·장식",
];

export const styles: AssetStyle[] = [
  {
    id: "clay",
    label: "클레이 3D",
    group: "입체·재질",
    treatment:
      "Soft sculpted 3D clay, rounded tactile shapes, matte clay surface, gentle studio shadows, playful sophisticated toy design.",
  },
  {
    id: "glass",
    label: "글라스 3D",
    group: "입체·재질",
    treatment:
      "Elegant translucent glass object, visible refraction and glass thickness, glossy soft studio reflections, premium digital icon finish.",
  },
  {
    id: "pop",
    label: "팝아트",
    group: "그래픽·캐릭터",
    treatment:
      "Bold pop-art graphic, thick dark comic outlines, flat saturated fills, halftone accents, energetic asymmetry.",
  },
  {
    id: "flat",
    label: "플랫 일러스트",
    group: "그래픽·캐릭터",
    treatment:
      "Contemporary flat vector-like illustration, generous clean colour blocks, no outlines, no texture, fresh witty composition.",
  },
  {
    id: "pixel",
    label: "픽셀 아트",
    group: "그래픽·캐릭터",
    treatment:
      "Deliberate crisp pixel art, limited retro game palette, hard aligned square pixels, no smoothing or anti-aliasing, professionally balanced game sprite.",
  },
  {
    id: "paper",
    label: "페이퍼 컷",
    group: "입체·재질",
    treatment:
      "Layered cut-paper relief, several coloured paper layers, visible paper thickness, precise cut edges and delicate dimensional shadows.",
  },
  {
    id: "collage",
    label: "에디토리얼 콜라주",
    group: "회화·인쇄",
    treatment:
      "Editorial cutout collage assembling photographic and sculptural cutouts into one compact witty composition, mixed paper textures, restrained palette.",
  },
  {
    id: "retro",
    label: "레트로 마스코트",
    group: "그래픽·캐릭터",
    treatment:
      "1930s rubber-hose cartoon style, bold fluid inking, flat colours with cream, cheerful vintage mascot feel, avoid fine engraving.",
  },
  {
    id: "bauhaus",
    label: "바우하우스",
    group: "간결·장식",
    treatment:
      "Bauhaus-inspired modular construction resolved in a few geometric colour planes, asymmetrical disciplined composition, intelligent negative space, crisp flat screenprint.",
  },
  {
    id: "artdeco",
    label: "아르데코",
    group: "간결·장식",
    treatment:
      "Art Deco emblem treatment, symmetrical fan-shaped ornament, elegant stepped geometry, precise architectural ornamental lines on warm ivory.",
  },
  {
    id: "psychedelic",
    label: "사이키델릭",
    group: "그래픽·캐릭터",
    treatment:
      "Psychedelic 1970s design with flowing wavy forms, bold groovy curvilinear shapes, joyful yet legible silhouette.",
  },
  {
    id: "gradient",
    label: "그라디언트 메쉬",
    group: "간결·장식",
    treatment:
      "Contemporary smooth mesh-gradient form, folded luminous shapes, sophisticated fluid digital gradients, no hand-drawn texture.",
  },
  {
    id: "watercolor",
    label: "수채화",
    group: "회화·인쇄",
    treatment:
      "Loose expressive watercolor, transparent washes, pigment blooms and soft paper texture, airy restrained painterly illustration.",
  },
  {
    id: "gouache",
    label: "과슈 페인팅",
    group: "회화·인쇄",
    treatment:
      "Rich opaque gouache illustration, visible broad brush strokes, simplified lively shapes, contemporary picture-book painting.",
  },
  {
    id: "linocut",
    label: "리노컷",
    group: "회화·인쇄",
    treatment:
      "Bold linocut block print, coarse carved gouges, strong ink masses and cream negative space, handmade print marks, robust not finely etched.",
  },
  {
    id: "monoline",
    label: "모노라인",
    group: "간결·장식",
    treatment:
      "Refined single continuous line of consistent weight describing the subject, elegant open white space, minimal crafted emblem.",
  },
  {
    id: "isometric",
    label: "아이소메트릭",
    group: "입체·재질",
    treatment:
      "Crisp isometric miniature, precise orthographic angle, compact 3D arrangement, flat shaded geometric surfaces.",
  },
  {
    id: "inflatable",
    label: "벌룬 3D",
    group: "입체·재질",
    treatment:
      "Playful inflated balloon object, glossy vinyl surface, soft inflated seams, buoyant puffy proportions, polished modern 3D render with clean studio lighting.",
  },
];

export function findStyle(id: unknown): AssetStyle | undefined {
  return styles.find((s) => s.id === id);
}
