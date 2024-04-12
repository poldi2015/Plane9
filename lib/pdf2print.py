import PyPDF2
import math
import argparse
import copy


# PyPDF2 removes the table of contents and the original numbering of pages in the thumbnails view

def add_margins( input_pdf, output_pdf, background_pdf, 
                margin_inner_mm, margin_outer_mm, margin_height_mm, 
                skip_page_nos = [], white_page_nos = [] ) :
    with open( input_pdf, 'rb' ) as file:
        margin_inner = math.floor( margin_inner_mm  * 2.8346 )
        margin_outer = math.floor( margin_outer_mm  * 2.8346 )
        margin_height = math.floor( margin_height_mm  * 2.8346 )

        pdf_reader = PyPDF2.PdfReader( file )        
        pdf_writer = PyPDF2.PdfWriter()
        
        # Read background color page
        sample_page = pdf_reader.pages[ 0 ]
        background_page = create_background_page( background_pdf, 
                                            sample_page.mediabox.width + margin_inner + margin_outer, 
                                            sample_page.mediabox.height + ( margin_height  * 2 ) ) \
                        if background_pdf else None    
        
        page_range =  get_page_range( pdf_reader, skip_page_nos  )
        for page_num in  page_range:
            inpage = pdf_reader.pages[ page_num ]

            # Create empty page
            outpage = create_empty_page( inpage, margin_inner, margin_outer, margin_height )

            # Add original page
            margin_shift_width = margin_inner if ( page_num % 2 ) == 1 else margin_outer
            margin_shift_height = margin_height
            if not is_white_page( page_num, white_page_nos ) :
                if background_page : outpage.merge_page( background_page )
            inpage.add_transformation( PyPDF2.Transformation().translate(  margin_shift_width, margin_shift_height ), expand = True )
            outpage.merge_page( inpage )

            # Write page to output
            pdf_writer.add_page( outpage )            

            # If page number is odd add a blank page at the end
            if ( len( page_range ) % 2 ) == 0 and page_num == page_range[-1]:
                blankpage =  create_empty_page( inpage, margin_inner, margin_outer, margin_height )
                pdf_writer.add_page( blankpage )

        # Write output file
        with open( output_pdf, 'wb' ) as output_file:
            pdf_writer.write( output_file )            

def create_background_page( input_pdf, width, height ) :
    file = open( input_pdf, 'rb' )
    pdf_reader = PyPDF2.PdfReader( file )
    inpage = pdf_reader.pages[ 0 ]        
    inpage.scale_to( float(width), float(height) )
    return inpage

def create_empty_page( inpage, margin_inner, margin_outer, margin_height ) :
    return PyPDF2.PageObject.create_blank_page(
                width =  inpage.mediabox.width  + margin_inner + margin_outer,  
                height = inpage.mediabox.height + 2 * margin_height )

def extract_page( input_pdf, output_pdf, page_num ) :
    with open( input_pdf, 'rb' ) as file:
        pdf_reader = PyPDF2.PdfReader( file )
        pdf_writer = PyPDF2.PdfWriter()

        if page_num < 0 :
            page_num = len( pdf_reader.pages ) + page_num

        inpage = pdf_reader.pages[ page_num ]
        pdf_writer.add_page( inpage )            

        with open( output_pdf, 'wb' ) as output_file:
            pdf_writer.write( output_file )


def get_page_range( pdf_reader, skip_page_nos = [] ) :
    skip_page_nos = list( map( lambda x : int( x ) if int( x ) >= 0 else int( len( pdf_reader.pages ) + x ), skip_page_nos ) )
    return [ i for i in range ( 0, len( pdf_reader.pages ) - 1 ) if int( i ) not in skip_page_nos ]    

def is_white_page( page_no, white_page_nos = [] ) :
    return int( page_no ) in white_page_nos


if __name__ == "__main__" :
    parser = argparse.ArgumentParser( prog = "pdf2book", description  = "Converts a PDF to book print format" )
    parser.add_argument( 'inpdf', help = "The input PDF" )
    parser.add_argument( 'outpdf', help = "The output PDF" )
    parser.add_argument( 'coverfrontpdf', nargs = '?', help = "The output cover front page PDF" )
    parser.add_argument( 'coverbackpdf', nargs = '?', help = "The output cover back page PDF" )
    parser.add_argument( '-B', '--pdfbackground', help = "page background (image) as pdf" )
    parser.add_argument( '-I', '--margin_inner',  help = "inner margin width in mm", type = int, default = 3 )
    parser.add_argument( '-O', '--margin_outer',  help = "outer margin width in mm", type = int, default = 3 )
    parser.add_argument( '-H', '--margin_height',  help = "Margin height in mm", type = int, default = 3 )
    parser.add_argument( '-P', '--skip_page',  help = "Skips the page with this number (starting from 0)", type = int, action = 'append',  
                        default = [] )
    parser.add_argument( '-W', '--white_page',  help = "Pages to which not add background", type = int, action = 'append', 
                        default = [] )
    args = parser.parse_args()
    
    add_margins( args.inpdf, args.outpdf, args.pdfbackground, 
                margin_inner_mm = args.margin_inner, margin_outer_mm = args.margin_outer, margin_height_mm = args.margin_height, skip_page_nos = args.skip_page,
                white_page_nos = args.white_page  )
    
    if args.coverfrontpdf :
        extract_page( args.inpdf, args.coverfrontpdf, 0 )
    if args.coverbackpdf :
        extract_page( args.inpdf, args.coverbackpdf, -1 )        
