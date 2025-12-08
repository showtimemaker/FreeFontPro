#!/usr/bin/env -S deno run --allow-read --allow-write
/**
 * 生成字体预览 SVG 图片脚本
 * 
 * 遍历 FreeFontPro/Resources/FreeFont 目录下的所有字体文件，
 * 为每个字体生成 SVG 矢量预览图片，保存在与字体文件相同的目录中。
 * 并将生成的 SVG 文件注册为 ODR (On-Demand Resources) 资源。
 */

import { walk } from "jsr:@std/fs";
import { dirname, join, basename, extname, relative } from "jsr:@std/path";
import { renderTextToSVG } from "./freefont.ts";

/**
 * 查找所有字体文件
 */
async function* findFontFiles(rootDir: string): AsyncGenerator<string> {
  const fontExtensions = [".ttf", ".otf", ".ttc"];
  
  for await (const entry of walk(rootDir, {
    exts: fontExtensions.map(ext => ext.slice(1)), // 移除开头的点
    followSymlinks: false,
  })) {
    if (entry.isFile) {
      yield entry.path;
    }
  }
}

/**
 * 删除所有之前生成的预览图片
 */
async function deletePreviewImages(rootDir: string): Promise<number> {
  let deletedCount = 0;
  
  for await (const entry of walk(rootDir, {
    match: [/_preview.*\.svg$/],
    followSymlinks: false,
  })) {
    if (entry.isFile) {
      try {
        await Deno.remove(entry.path);
        deletedCount++;
        console.log(`  🗑️  已删除: ${basename(entry.path)}`);
      } catch (e) {
        console.log(`  ⚠️  删除失败 ${basename(entry.path)}: ${e}`);
      }
    }
  }
  
  return deletedCount;
}

/**
 * 根据字体名称返回适合的预览文本列表
 */
function getPreviewTexts(fontName: string): Array<[string, string]> {
  const fontNameLower = fontName.toLowerCase();
  
  // 数字预览文本（所有字体都生成）
  const numberText = "0123456789";
  
  // 英文预览文本（所有字体都生成）
  const englishText = "The quick brown fox jumps over the lazy dog";
  
  const results: Array<[string, string]> = [];
  
  // 根据字体类型添加原语言预览（英语除外）
  if (fontNameLower.includes("cn") || fontNameLower.includes("hans")) {
    // 简体中文 - 优雅的诗句
    results.push(["cn", "春江潮水连海平 海上明月共潮生"]);
  } else if (
    fontNameLower.includes("hc") ||
    fontNameLower.includes("hant") ||
    fontNameLower.includes("tc")
  ) {
    // 繁体中文 - 优雅的诗句
    results.push(["tc", "春江潮水連海平 海上明月共潮生"]);
  } else if (fontNameLower.includes("jp") || fontNameLower.includes("ja")) {
    // 日文 - 优美的俳句风格
    results.push(["jp", "春の夜の 夢のごとし たゞ一夜"]);
  } else if (fontNameLower.includes("kr") || fontNameLower.includes("ko")) {
    // 韩文 - 优美的韩文句子
    results.push(["kr", "아름다운 세상을 꿈꾸며 함께 걸어가요"]);
  }
  
  // 添加英文和数字（所有字体）
  results.push(["en", englishText]);
  results.push(["num", numberText]);
  
  return results;
}

/**
 * 生成预览 SVG 文件
 */
async function generatePreviewImage(
  fontPath: string,
  outputPath: string,
  previewText: string,
): Promise<boolean> {
  try {
    // 使用 renderTextToSVG 生成 SVG
    const svg = renderTextToSVG(previewText, fontPath);
    
    // 写入文件
    await Deno.writeTextFile(outputPath, svg);
    
    console.log(`  ✅ 已生成预览图片: ${basename(outputPath)}`);
    return true;
  } catch (e) {
    console.log(`  ❌ 生成预览失败: ${e}`);
    return false;
  }
}

/**
 * 更新 project.pbxproj 文件，添加 ODR 资源标签
 */
async function updateProjectPbxproj(
  projectPath: string,
  odrFiles: Array<{ relativePath: string; tag: string }>,
) {
  console.log(`\n📝 更新 project.pbxproj 文件...`);
  
  try {
    // 读取 project.pbxproj 文件
    const pbxprojContent = await Deno.readTextFile(projectPath);
    
    // 构建 assetTagsByRelativePath 内容（包括字体文件和 SVG）
    const assetTagsLines = odrFiles
      .map(({ relativePath, tag }) => `\t\t\t\t${relativePath} = (${tag}, );`)
      .join("\n");
    
    // 构建 KnownAssetTags 内容（去重）
    const uniqueTags = [...new Set(odrFiles.map(({ tag }) => tag))];
    const knownAssetTags = uniqueTags
      .map((tag) => `\t\t\t\t\t${tag},`)
      .join("\n");
    
    // 查找并替换 assetTagsByRelativePath 部分
    const assetTagsRegex = /(assetTagsByRelativePath = \{)\s*([\s\S]*?)(\s*\};)/;
    let updatedContent = pbxprojContent;
    
    if (assetTagsRegex.test(pbxprojContent)) {
      // 替换现有的 assetTagsByRelativePath（不添加额外的空行）
      updatedContent = pbxprojContent.replace(
        assetTagsRegex,
        `$1\n${assetTagsLines}$3`,
      );
    }
    
    // 查找并替换 KnownAssetTags 部分
    const knownAssetTagsRegex = /(KnownAssetTags = \()\s*([\s\S]*?)(\s*\);)/;
    
    if (knownAssetTagsRegex.test(updatedContent)) {
      // 替换现有的 KnownAssetTags（不添加额外的空行）
      updatedContent = updatedContent.replace(
        knownAssetTagsRegex,
        `$1\n${knownAssetTags}$3`,
      );
    }
    
    // 写回文件
    await Deno.writeTextFile(projectPath, updatedContent);
    
    console.log(`✅ 已更新 project.pbxproj，添加了 ${odrFiles.length} 个文件，${uniqueTags.length} 个 ODR 资源标签`);
  } catch (e) {
    console.log(`❌ 更新 project.pbxproj 失败: ${e}`);
  }
}

/**
 * 主函数
 */
async function main() {
  // 设置路径
  const scriptDir = dirname(new URL(import.meta.url).pathname);
  const projectDir = dirname(scriptDir);
  const fontsDir = join(projectDir, "FreeFontPro", "Resources", "FreeFont");
  
  console.log(`🔍 查找字体文件: ${fontsDir}`);
  
  // 删除之前生成的预览图片
  console.log(`\n🗑️  清理旧的预览图片...`);
  const deletedCount = await deletePreviewImages(fontsDir);
  if (deletedCount > 0) {
    console.log(`✅ 已删除 ${deletedCount} 个旧预览图片\n`);
  } else {
    console.log(`✅ 没有找到需要删除的旧预览图片\n`);
  }
  
  // 查找所有字体文件
  const fontFiles: string[] = [];
  for await (const fontPath of findFontFiles(fontsDir)) {
    fontFiles.push(fontPath);
  }
  
  if (fontFiles.length === 0) {
    console.log("❌ 未找到任何字体文件");
    return;
  }
  
  console.log(`📝 找到 ${fontFiles.length} 个字体文件\n`);
  
  // 统计信息
  let successCount = 0;
  let failedCount = 0;
  const odrFiles: Array<{ relativePath: string; tag: string }> = [];
  
  // FreeFontPro 目录路径（用于计算相对路径）
  const freeFontProDir = join(projectDir, "FreeFontPro");
  
  // 为每个字体生成预览图片，并收集字体文件和 SVG 文件用于 ODR
  for (let i = 0; i < fontFiles.length; i++) {
    const fontPath = fontFiles[i];
    const fontName = basename(fontPath);
    const fontDir = dirname(fontPath);
    
    // 获取所有预览文本配置
    const previewConfigs = getPreviewTexts(fontName);
    
    console.log(`[${i + 1}/${fontFiles.length}] 处理: ${fontName}`);
    
    // 添加字体文件本身到 ODR 列表
    const fontRelativePath = relative(freeFontProDir, fontPath);
    const fontTag = basename(fontPath); // 使用完整文件名作为 tag
    odrFiles.push({ relativePath: fontRelativePath, tag: fontTag });
    
    // 为每种预览文本生成图片
    for (const [suffix, previewText] of previewConfigs) {
      // 生成输出文件名（SVG 格式）
      const baseName = basename(fontPath, extname(fontPath));
      const outputName = `${baseName}_preview_${suffix}.svg`;
      const outputPath = join(fontDir, outputName);
      
      console.log(`  🎨 生成 ${suffix} 预览...`);
      
      // 生成预览图片
      if (await generatePreviewImage(fontPath, outputPath, previewText)) {
        successCount++;
        
        // 计算相对路径（相对于 FreeFontPro 目录）
        const relativePath = relative(freeFontProDir, outputPath);
        
        // 使用文件名（不含扩展名）作为 tag
        const tag = basename(outputPath, ".svg");
        
        odrFiles.push({ relativePath, tag });
      } else {
        failedCount++;
      }
    }
    
    console.log();
  }
  
  // 打印统计信息
  console.log("=".repeat(60));
  console.log(`✨ 处理完成!`);
  console.log(`   成功: ${successCount} 个 SVG`);
  console.log(`   失败: ${failedCount} 个 SVG`);
  console.log(`   总计: ${successCount + failedCount} 个 SVG`);
  console.log(`   字体文件: ${fontFiles.length} 个`);
  console.log("=".repeat(60));
  
  // 更新 project.pbxproj 文件（包括字体文件和 SVG）
  if (odrFiles.length > 0) {
    const pbxprojPath = join(
      projectDir,
      "FreeFontPro.xcodeproj",
      "project.pbxproj",
    );
    await updateProjectPbxproj(pbxprojPath, odrFiles);
  }
}

// 运行主函数
if (import.meta.main) {
  main();
}
