#!/usr/bin/env python3
"""
生成字体预览图片脚本

遍历 FreeFontPro/Resources/FreeFont 目录下的所有字体文件，
为每个字体生成预览图片，保存在与字体文件相同的目录中。
"""

import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def find_font_files(root_dir):
    """
    递归查找所有字体文件
    
    Args:
        root_dir: 根目录路径
        
    Returns:
        字体文件路径列表
    """
    font_extensions = ('.ttf', '.otf', '.ttc')
    font_files = []
    
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith(font_extensions):
                font_files.append(os.path.join(root, file))
    
    return font_files


def get_preview_text(font_name):
    """
    根据字体名称返回适合的预览文本
    
    Args:
        font_name: 字体文件名
        
    Returns:
        预览文本字符串
    """
    font_name_lower = font_name.lower()
    
    if 'cn' in font_name_lower or 'hans' in font_name_lower:
        return "欢迎使用FreeFont Pro"
    elif 'hc' in font_name_lower or 'hant' in font_name_lower or 'tc' in font_name_lower:
        return "歡迎使用FreeFont Pro"
    elif 'jp' in font_name_lower or 'ja' in font_name_lower:
        return "FreeFont Proへようこそ"
    else:
        return "Welcome to FreeFont Pro"


def calculate_text_size(draw, text, font):
    """
    计算文本的实际渲染尺寸（使用实际边界框，紧凑布局）
    
    Args:
        draw: ImageDraw 对象
        text: 文本内容
        font: 字体对象
        
    Returns:
        (width, height, offset_y) 元组
        offset_y 是文本顶部相对于基线的偏移量
    """
    # 获取文本边界框（相对于 (0, 0) 位置）
    bbox = draw.textbbox((0, 0), text, font=font, anchor='lt')
    
    # bbox 格式: (left, top, right, bottom)
    width = bbox[2] - bbox[0]
    height = bbox[3] - bbox[1]
    offset_y = bbox[1]  # 顶部偏移量（可能为负数）
    
    return width, height, offset_y


def generate_preview_image(font_path, output_path, preview_text=None, font_size=48, padding=0):
    """
    生成字体预览图片
    
    Args:
        font_path: 字体文件路径
        output_path: 输出图片路径
        preview_text: 预览文本（如果为 None，则自动检测）
        font_size: 字体大小（默认 48）
        padding: 图片边距（默认 0）

    Returns:
        True 表示成功，False 表示失败
    """
    try:
        # 如果未提供预览文本，自动检测
        if preview_text is None:
            preview_text = get_preview_text(os.path.basename(font_path))
        
        # 加载字体
        try:
            font = ImageFont.truetype(font_path, font_size)
        except Exception as e:
            print(f"  ⚠️  无法加载字体: {e}")
            return False
        
        # 创建临时图像来计算文本尺寸
        temp_image = Image.new('RGBA', (1, 1), (255, 255, 255, 0))
        temp_draw = ImageDraw.Draw(temp_image)
        
        # 计算文本实际尺寸和偏移
        text_width, text_height, offset_y = calculate_text_size(temp_draw, preview_text, font)
        
        # 创建最终图像（宽高自适应 + 边距）
        # 高度需要考虑负偏移（文本可能从基线上方开始）
        image_width = text_width + padding * 2
        image_height = text_height + padding * 2
        
        # 创建透明背景图像（使用 RGBA 模式）
        image = Image.new('RGBA', (image_width, image_height), (255, 255, 255, 0))
        draw = ImageDraw.Draw(image)
        
        # 计算文本位置（补偿负偏移）
        x = padding
        y = padding - offset_y  # 减去偏移量，将文本顶部对齐到 padding 位置
        
        # 绘制文本（使用 anchor='lt' 确保从左上角开始）
        draw.text((x, y), preview_text, fill='black', font=font, anchor='lt')
        
        # 保存图片
        image.save(output_path, 'PNG', optimize=True)
        
        print(f"  ✅ 已生成预览图片: {os.path.basename(output_path)} ({image_width}x{image_height})")
        return True
        
    except Exception as e:
        print(f"  ❌ 生成预览失败: {e}")
        return False


def main():
    """主函数"""
    # 设置路径
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent
    fonts_dir = project_dir / "FreeFontPro" / "Resources" / "FreeFont"
    
    print(f"🔍 查找字体文件: {fonts_dir}")
    
    # 查找所有字体文件
    font_files = find_font_files(fonts_dir)
    
    if not font_files:
        print("❌ 未找到任何字体文件")
        return
    
    print(f"📝 找到 {len(font_files)} 个字体文件\n")
    
    # 统计信息
    success_count = 0
    failed_count = 0
    
    # 为每个字体生成预览图片
    for i, font_path in enumerate(font_files, 1):
        font_name = os.path.basename(font_path)
        font_dir = os.path.dirname(font_path)
        
        # 生成输出文件名（将字体扩展名替换为 .png）
        output_name = os.path.splitext(font_name)[0] + '_preview.png'
        output_path = os.path.join(font_dir, output_name)
        
        print(f"[{i}/{len(font_files)}] 处理: {font_name}")
        
        # 生成预览图片
        if generate_preview_image(font_path, output_path):
            success_count += 1
        else:
            failed_count += 1
        
        print()
    
    # 打印统计信息
    print("=" * 60)
    print(f"✨ 处理完成!")
    print(f"   成功: {success_count} 个")
    print(f"   失败: {failed_count} 个")
    print(f"   总计: {len(font_files)} 个")
    print("=" * 60)


if __name__ == "__main__":
    main()
