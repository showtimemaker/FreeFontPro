let FreeFont: [FreeFontModel] = [
    FreeFontModel(
        author: "Astro-2539",
        categories: ["pixel", "monospace"],
        languages: ["en", "zh-Hans", "zh-Hant", "ja"],
        names: ["Z Labs Bitmap 12px", "Z Labs Bitmap 12px", "Z Labs Bitmap 12px", "Z Labs Bitmap 12px"],
        descriptions: [
          "Z Labs Bitmap 12px is a pixel font with a size of 12px, featuring variant glyphs for Mainland China, Hong Kong, and Japan, with monospaced design for Latin characters.",
          "「Z Labs Bitmap 12px」是一款规格为 12px 的像素字体，具有中国大陆、中国香港、日本三种变体字形，西文字体按等宽规格设计。",
          "「Z Labs Bitmap 12px」は、12pxのピクセルフォントで、中国本土、中国香港、日本のバリアントグリフを備え、ラテン文字は等幅デザインとなっています。",
          "「Z Labs Bitmap 12px」係一款規格為 12px 嘅像素字體，具有中國大陸、中国香港、日本三種變體字形，西文字體按等寬規格設計。"
        ],
        weights: ["Regular"],
        license: "SIL Open Font License 1.1",
        licenseUrl: "https://github.com/Astro-2539/ZLabs-Bitmap/blob/main/LICENSE-OFL",
        website: "https://github.com/Astro-2539/ZLabs-Bitmap",
        copyright: "Copyright (c) 2023-2025, Astro_2539",
        postscriptNames: [
            .init(
              language: "zh-Hans",
              weight: "Regular",
              postscriptName: "Z-Labs-Bitmap-12px-CN-Regular",
              fileName: "ZLabsBitmap_12px_CN",
              fileExt: "ttf",
              version: "Version 0.98",
              previewTag: "ZLabsBitmap_12px_CN_preview_cn",
              previewEnTag: "ZLabsBitmap_12px_CN_preview_en",
              previewNumTag: "ZLabsBitmap_12px_CN_preview_num"
            ),
            .init(
              language: "zh-Hant",
              weight: "Regular",
              postscriptName: "Z-Labs-Bitmap-12px-HC-Regular",
              fileName: "ZLabsBitmap_12px_HC",
              fileExt: "ttf",
              version: "Version 1.0_HC",
              previewTag: "ZLabsBitmap_12px_HC_preview_tc",
              previewEnTag: "ZLabsBitmap_12px_HC_preview_en",
              previewNumTag: "ZLabsBitmap_12px_HC_preview_num"
            ),
            .init(
              language: "ja",
              weight: "Regular",
              postscriptName: "Z-Labs-Bitmap-12px-JP-Regular",
              fileName: "ZLabsBitmap_12px_JP",
              fileExt: "ttf",
              version: "Version 1.01_JP",
              previewTag: "ZLabsBitmap_12px_JP_preview_jp",
              previewEnTag: "ZLabsBitmap_12px_JP_preview_en",
              previewNumTag: "ZLabsBitmap_12px_JP_preview_num"
            )
        ]
    ),
    FreeFontModel(
        author: "42dot",
        categories: ["korean", "latin", "menu"],
        languages: ["en"],
        names: ["42dot Sans"],
        descriptions: [
          "42dot Sans is the corporate typeface for 42dot, designed to encapsulate the brand’s core identity and philosophy. With its harmonious balance of straight lines that represent cutting-edge technology and gentle curves that exude user-friendliness, 42dot Sans reflects the perfect synergy between precision and approachability.",
        ],
        weights: ["Regular"],
        license: "SIL Open Font License 1.1",
        licenseUrl: "https://github.com/42dot/42dot-Sans/LICENSE-OFL",
        website: "https://github.com/42dot/42dot-Sans",
        copyright: "Copyright (c) 2023-2025, Astro_2539",
        postscriptNames: [
            .init(
              language: "en",
              weight: "Regular",
              postscriptName: "42dotSans-Light",
              fileName: "42dotSans[wght]",
              fileExt: "ttf",
              version: "Version 0.98",
              previewTag: "42dotSans[wght]_preview_en",
              previewEnTag: "42dotSans[wght]_preview_en",
              previewNumTag: "42dotSans[wght]_preview_num"
            ),
        ]
    )
]
