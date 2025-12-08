
import * as fontkit from "npm:fontkit@2.0.4";
import type { Font } from "npm:@types/fontkit@2.0.8";

export function renderTextToSVG(
  text: string,
  fontpath: string,
) {
  const font = fontkit.openSync(fontpath) as Font;
  const run = font.layout(text);
  let advanceWidth = 0;
  const glyphSVGs = run.glyphs.map((glyph, index) => {
    const xAdvance = run.positions[index].xAdvance;
    const translateX = advanceWidth;
    advanceWidth += xAdvance;

    // 生成每个字形的 SVG path（无缩放）
    const pathData = glyph.path.toSVG();
    return `<g transform="translate(${translateX}, 0)"><path d="${pathData}"/></g>`;
  }).join("");

  // SVG 高度：使用 font.ascent（字体的最大高度）
  const svgHeight = font.ascent - font.descent + font.lineGap;
  // 生成 SVG 字符串
  const svg = `
<svg xmlns="http://www.w3.org/2000/svg" width="${advanceWidth}" height="${svgHeight}" viewBox="0 0 ${advanceWidth} ${svgHeight}">
  <g transform="translate(0, ${font.ascent}) scale(1, -1)">${glyphSVGs}</g>
</svg>`;
  return svg;
}

// export function renderTextToSVGFixedWidth(
//   text: string,
//   font: Font,
// ) {
//   const run = font.layout(text);
//   let advanceWidth = 0;
//   const glyphSVGs = run.glyphs.map((glyph, index) => {
//     const xAdvance = run.positions[index].xAdvance;
//     const translateX = advanceWidth;
//     advanceWidth += xAdvance;

//     // 生成每个字形的 SVG path（无缩放）
//     const pathData = glyph.path.toSVG();
//     return `<g transform="translate(${translateX}, 0)"><path d="${pathData}"/></g>`;
//   }).join("");

//   // SVG 高度：使用 font.ascent（字体的最大高度）
//   const svgHeight = font.ascent - font.descent + font.lineGap;
//   const svgWidth = Math.ceil(advanceWidth / svgHeight) * svgHeight;
//   // 生成 SVG 字符串
//   const svg = `
// <svg xmlns="http://www.w3.org/2000/svg" width="${svgWidth}" height="${svgHeight}" viewBox="${
//     (svgWidth - advanceWidth) / 2
//   } 0 ${advanceWidth} ${svgHeight}">
//   <g transform="translate(0, ${font.ascent}) scale(1, -1)">${glyphSVGs}</g>
// </svg>`;
//   return svg;
// }

// for await (const entry of walk(Deno.cwd() + "/freefont", { exts: ["otf", "ttf"] })) {
//   const font = await fontkit.open(entry.path) as Font;

//   const fileSize = await getFileSize(entry.path);
//   const fileHash = await getFileHash(entry.path);

//   // 更新 FreeFontMeta 中的字体信息
//   FreeFontMeta.data.forEach((fontMeta) => {
//     fontMeta.postscriptNames.forEach((psName) => {
//       if (psName.postscriptName === font.postscriptName) {
//         fontMeta.copyright = font.copyright;
//         psName.version = font.version.toString();
//         psName.size = fileSize;
//         psName.sha512 = fileHash;
//       }
//     });
//   });

//   FontMap.set(font.postscriptName, font);
//   console.debug(
//     `Loaded Font: ${font.familyName} ${font.postscriptName} ${entry.path}`,
//   );
// }

// function getFileSize(filePath: string): Promise<number> {
//   return Deno.stat(filePath).then((stat) => stat.size);
// }

// async function getFileHash(filePath: string): Promise<string> {
//   const data = await Deno.readFile(filePath);
//   const hashBuffer = await crypto.subtle.digest("SHA-512", data);
//   const hashArray = Array.from(new Uint8Array(hashBuffer));
//   return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
// }

// export const FontMap = new Map<string, Font>();

// export const FreeFontMeta = {
//   version: 2025113002,
//   data: [
//     {
//       id: "Z Labs Bitmap 12px",
//       categories: ["pixel", "monospace"],
//       languages: ["en", "zh-Hans", "zh-Hant", "ja"],
//       names: [
//         "Z Labs Bitmap 12px",
//         "Z Labs Bitmap 12px",
//         "Z Labs Bitmap 12px",
//         "Z Labs Bitmap 12px",
//       ],
//       descriptions: [
//         "Z Labs Bitmap 12px is a pixel font with a size of 12px, featuring variant glyphs for Mainland China, Hong Kong, and Japan, with monospaced design for Latin characters.",
//         "「Z Labs Bitmap 12px」是一款规格为 12px 的像素字体，具有中国大陆、中国香港、日本三种变体字形，西文字体按等宽规格设计。",
//         "「Z Labs Bitmap 12px」は、12pxのピクセルフォントで、中国本土、中国香港、日本のバリアントグリフを備え、ラテン文字は等幅デザインとなっています。",
//         "「Z Labs Bitmap 12px」係一款規格為 12px 嘅像素字體，具有中國大陸、中国香港、日本三種變體字形，西文字體按等寬規格設計。",
//       ],
//       author: "Astro-2539",
//       weights: ["Regular"],
//       license: "SIL Open Font License 1.1",
//       licenseUrl:
//         "https://github.com/Astro-2539/ZLabs-Bitmap/blob/main/LICENSE-OFL",
//       website: "https://github.com/Astro-2539/ZLabs-Bitmap",
//       copyright: "",
//       postscriptNames: [
//         {
//           language: "zh-Hans",
//           weight: "Regular",
//           postscriptName: "Z-Labs-Bitmap-12px-CN-Regular",
//           downloadUrls: [
//             "https://pub-1c7463665ba447febb66ff3cba0b76c5.r2.dev/ZLabsBitmap_12px/ZLabsBitmap_12px_CN.ttf",
//           ],
//           sha512: "",
//           size: 0,
//           version: "",
//         },
//         {
//           language: "zh-Hant",
//           weight: "Regular",
//           postscriptName: "Z-Labs-Bitmap-12px-HC-Regular",
//           downloadUrls: [
//             "https://pub-1c7463665ba447febb66ff3cba0b76c5.r2.dev/ZLabsBitmap_12px/ZLabsBitmap_12px_HK.ttf",
//           ],
//           sha512: "",
//           size: 0,
//           version: "",
//         },
//         {
//           language: "ja",
//           weight: "Regular",
//           postscriptName: "Z-Labs-Bitmap-12px-JP-Regular",
//           downloadUrls: [
//             "https://pub-1c7463665ba447febb66ff3cba0b76c5.r2.dev/ZLabsBitmap_12px/ZLabsBitmap_12px_JP.ttf",
//           ],
//           sha512: "",
//           size: 0,
//           version: "",
//         },
//         {
//           language: "en",
//           weight: "Regular",
//           postscriptName: "Z-Labs-Bitmap-12px-CN-Regular",
//           downloadUrls: [
//             "https://pub-1c7463665ba447febb66ff3cba0b76c5.r2.dev/ZLabsBitmap_12px/ZLabsBitmap_12px_CN.ttf",
//           ],
//           sha512: "",
//           size: 0,
//           version: "",
//         },
//       ],
//     },
//   ],
// };
