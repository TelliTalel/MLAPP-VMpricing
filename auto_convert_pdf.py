"""
Automatic MD to PDF converter - No user input required
"""
import os
import subprocess

def convert_to_pdf():
    """Try to convert markdown to PDF automatically"""
    
    print("="*60)
    print("Auto-Converting CRISP-DM Report to PDF")
    print("="*60)
    
    if not os.path.exists('CRISP_DM_Report.md'):
        print("\n[ERROR] CRISP_DM_Report.md not found!")
        return False
    
    # Try WeasyPrint (most reliable for Python)
    print("\n[INFO] Attempting conversion with WeasyPrint...")
    try:
        import markdown
        from weasyprint import HTML
        
        # Read markdown
        with open('CRISP_DM_Report.md', 'r', encoding='utf-8') as f:
            md_text = f.read()
        
        # Convert to HTML
        html_content = markdown.markdown(
            md_text,
            extensions=['tables', 'fenced_code', 'toc']
        )
        
        # Add professional CSS
        styled_html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                @page {{
                    size: A4;
                    margin: 2cm;
                    @bottom-right {{
                        content: "Page " counter(page) " of " counter(pages);
                        font-size: 9pt;
                        color: #666;
                    }}
                }}
                body {{
                    font-family: 'Segoe UI', Arial, sans-serif;
                    line-height: 1.7;
                    color: #333;
                    font-size: 11pt;
                }}
                h1 {{
                    color: #667eea;
                    border-bottom: 4px solid #667eea;
                    padding-bottom: 12px;
                    margin-top: 40px;
                    margin-bottom: 20px;
                    page-break-before: always;
                    font-size: 26pt;
                }}
                h1:first-of-type {{
                    page-break-before: avoid;
                    margin-top: 0;
                }}
                h2 {{
                    color: #764ba2;
                    border-bottom: 2px solid #764ba2;
                    padding-bottom: 8px;
                    margin-top: 30px;
                    margin-bottom: 15px;
                    font-size: 20pt;
                }}
                h3 {{
                    color: #667eea;
                    margin-top: 24px;
                    margin-bottom: 12px;
                    font-size: 16pt;
                }}
                h4 {{
                    color: #555;
                    margin-top: 18px;
                    font-size: 14pt;
                }}
                table {{
                    border-collapse: collapse;
                    width: 100%;
                    margin: 20px 0;
                    font-size: 10pt;
                    page-break-inside: avoid;
                }}
                th {{
                    background: linear-gradient(135deg, #667eea, #764ba2);
                    color: white;
                    padding: 12px 8px;
                    text-align: left;
                    font-weight: 600;
                }}
                td {{
                    border: 1px solid #ddd;
                    padding: 10px 8px;
                }}
                tr:nth-child(even) {{
                    background-color: #f8f9fa;
                }}
                code {{
                    background-color: #f4f4f4;
                    padding: 3px 6px;
                    border-radius: 4px;
                    font-family: 'Consolas', 'Courier New', monospace;
                    font-size: 9.5pt;
                    color: #d63384;
                }}
                pre {{
                    background-color: #f8f9fa;
                    padding: 16px;
                    border-radius: 6px;
                    border-left: 4px solid #667eea;
                    overflow-x: auto;
                    font-size: 9pt;
                    line-height: 1.4;
                }}
                pre code {{
                    background: none;
                    padding: 0;
                    color: #333;
                }}
                blockquote {{
                    border-left: 5px solid #667eea;
                    padding-left: 20px;
                    margin-left: 0;
                    color: #666;
                    font-style: italic;
                    background-color: #f8f9fa;
                    padding: 15px 15px 15px 20px;
                    border-radius: 0 6px 6px 0;
                }}
                hr {{
                    border: none;
                    border-top: 2px solid #e9ecef;
                    margin: 30px 0;
                }}
                ul, ol {{
                    margin: 15px 0;
                    padding-left: 25px;
                }}
                li {{
                    margin: 8px 0;
                }}
                strong {{
                    color: #495057;
                    font-weight: 600;
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
        
        file_size = os.path.getsize('CRISP_DM_Report.pdf') / 1024
        print("\n" + "="*60)
        print("[SUCCESS] PDF Generated!")
        print("="*60)
        print(f"\n[OK] File: CRISP_DM_Report.pdf")
        print(f"[INFO] Size: {file_size:.2f} KB")
        print(f"[INFO] Location: {os.path.abspath('CRISP_DM_Report.pdf')}")
        return True
        
    except ImportError as e:
        print(f"\n[ERROR] Missing dependencies: {e}")
        print("\n[INFO] To install dependencies, run:")
        print("       pip install weasyprint markdown")
        return False
    except Exception as e:
        print(f"\n[ERROR] Conversion failed: {e}")
        return False

if __name__ == '__main__':
    try:
        success = convert_to_pdf()
        if not success:
            print("\n" + "="*60)
            print("Alternative: Online Converters")
            print("="*60)
            print("\n1. https://md2pdf.netlify.app/")
            print("2. https://www.markdowntopdf.com/")
            print("3. https://dillinger.io/ (export as PDF)")
    except KeyboardInterrupt:
        print("\n\n[INFO] Conversion cancelled by user")
