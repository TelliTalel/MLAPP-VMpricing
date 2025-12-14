"""
Script to convert CRISP_DM_Report.md to PDF
Requires: pip install markdown reportlab pypandoc
"""

import os
import subprocess
import sys

def check_pandoc():
    """Check if pandoc is installed"""
    try:
        subprocess.run(['pandoc', '--version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def convert_with_pandoc():
    """Convert using pandoc (best quality)"""
    print("[INFO] Converting with pandoc...")
    try:
        cmd = [
            'pandoc',
            'CRISP_DM_Report.md',
            '-o', 'CRISP_DM_Report.pdf',
            '--pdf-engine=xelatex',
            '-V', 'geometry:margin=1in',
            '-V', 'fontsize=11pt',
            '-V', 'documentclass=article',
            '--toc',
            '--toc-depth=3',
            '--number-sections',
            '--highlight-style=tango'
        ]
        subprocess.run(cmd, check=True)
        print("[OK] PDF generated successfully with pandoc!")
        return True
    except Exception as e:
        print(f"[ERROR] Pandoc conversion failed: {e}")
        return False

def convert_with_markdown2pdf():
    """Convert using markdown2pdf (alternative)"""
    print("[INFO] Converting with markdown2pdf...")
    try:
        from markdown2pdf import convert_markdown_to_pdf
        
        with open('CRISP_DM_Report.md', 'r', encoding='utf-8') as f:
            markdown_text = f.read()
        
        convert_markdown_to_pdf(markdown_text, 'CRISP_DM_Report.pdf')
        print("[OK] PDF generated successfully with markdown2pdf!")
        return True
    except Exception as e:
        print(f"[ERROR] markdown2pdf conversion failed: {e}")
        return False

def convert_with_weasyprint():
    """Convert using WeasyPrint"""
    print("[INFO] Converting with WeasyPrint...")
    try:
        import markdown
        from weasyprint import HTML, CSS
        
        # Read markdown
        with open('CRISP_DM_Report.md', 'r', encoding='utf-8') as f:
            md_text = f.read()
        
        # Convert to HTML
        html_content = markdown.markdown(
            md_text,
            extensions=['tables', 'fenced_code', 'codehilite', 'toc']
        )
        
        # Add CSS styling
        styled_html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                @page {{
                    size: A4;
                    margin: 2cm;
                }}
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                }}
                h1 {{
                    color: #667eea;
                    border-bottom: 3px solid #667eea;
                    padding-bottom: 10px;
                    page-break-before: always;
                }}
                h1:first-of-type {{
                    page-break-before: avoid;
                }}
                h2 {{
                    color: #764ba2;
                    border-bottom: 2px solid #764ba2;
                    padding-bottom: 5px;
                    margin-top: 30px;
                }}
                h3 {{
                    color: #667eea;
                    margin-top: 20px;
                }}
                table {{
                    border-collapse: collapse;
                    width: 100%;
                    margin: 20px 0;
                }}
                th {{
                    background-color: #667eea;
                    color: white;
                    padding: 10px;
                    text-align: left;
                }}
                td {{
                    border: 1px solid #ddd;
                    padding: 8px;
                }}
                tr:nth-child(even) {{
                    background-color: #f2f2f2;
                }}
                code {{
                    background-color: #f4f4f4;
                    padding: 2px 6px;
                    border-radius: 3px;
                    font-family: monospace;
                }}
                pre {{
                    background-color: #f4f4f4;
                    padding: 15px;
                    border-radius: 5px;
                    overflow-x: auto;
                }}
                blockquote {{
                    border-left: 4px solid #667eea;
                    padding-left: 15px;
                    margin-left: 0;
                    color: #666;
                }}
                .page-break {{
                    page-break-after: always;
                }}
            </style>
        </head>
        <body>
            {html_content}
        </body>
        </html>
        """
        
        # Convert to PDF
        HTML(string=styled_html).write_pdf('CRISP_DM_Report.pdf')
        print("[OK] PDF generated successfully with WeasyPrint!")
        return True
    except Exception as e:
        print(f"[ERROR] WeasyPrint conversion failed: {e}")
        return False

def main():
    print("="*60)
    print("CRISP-DM Report PDF Converter")
    print("="*60)
    
    # Check if markdown file exists
    if not os.path.exists('CRISP_DM_Report.md'):
        print("[ERROR] CRISP_DM_Report.md not found!")
        return
    
    print("\nAvailable conversion methods:")
    print("1. Pandoc (recommended - best quality)")
    print("2. WeasyPrint (good quality, no external dependencies)")
    print("3. Try all methods")
    
    choice = input("\nChoose method (1-3) or press Enter for auto: ").strip()
    
    success = False
    
    if choice == '1':
        success = convert_with_pandoc()
    elif choice == '2':
        success = convert_with_weasyprint()
    else:
        # Try methods in order of preference
        print("\n[INFO] Trying automatic conversion...\n")
        
        if check_pandoc():
            success = convert_with_pandoc()
        
        if not success:
            print("\n[WARNING] Pandoc not available, trying WeasyPrint...")
            success = convert_with_weasyprint()
        
        if not success:
            print("\n[WARNING] WeasyPrint not available, trying markdown2pdf...")
            success = convert_with_markdown2pdf()
    
    if success:
        print("\n" + "="*60)
        print("[SUCCESS] PDF GENERATED!")
        print("="*60)
        print(f"\n[OK] PDF created: {os.path.abspath('CRISP_DM_Report.pdf')}")
        print(f"[INFO] File size: {os.path.getsize('CRISP_DM_Report.pdf') / 1024:.2f} KB")
    else:
        print("\n" + "="*60)
        print("[ERROR] CONVERSION FAILED")
        print("="*60)
        print("\nManual conversion options:")
        print("\n1. Install Pandoc:")
        print("   Windows: https://pandoc.org/installing.html")
        print("   Then run: pandoc CRISP_DM_Report.md -o CRISP_DM_Report.pdf")
        print("\n2. Install WeasyPrint:")
        print("   pip install weasyprint markdown")
        print("\n3. Use online converter:")
        print("   https://md2pdf.netlify.app/")
        print("   https://www.markdowntopdf.com/")

if __name__ == '__main__':
    main()
