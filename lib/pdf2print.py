import PyPDF2
import math
import argparse
import copy


# PyPDF2 removes the table of contents and the original numbering of pages in the thumbnails view

def add_margins( input_pdf, output_pdf, margin_width_mm, margin_height_mm, skip_page_nos = [] ) :
    with open( input_pdf, 'rb' ) as file:
        margin_width = math.floor( margin_width_mm  * 2.8346 )
        margin_height = math.floor( margin_height_mm  * 2.8346 )

        pdf_reader = PyPDF2.PdfReader( file )
        pdf_writer = PyPDF2.PdfWriter()

        page_range =  get_page_range( pdf_reader, skip_page_nos  )
        for page_num in  page_range:
            inpage = pdf_reader.pages[ page_num ]

            # Create empty page
            outpage =  create_empty_page( inpage, margin_width, margin_height )
            outpage.merge_page( outpage )

            # Add original page
            inpage.add_transformation( PyPDF2.Transformation().translate(  margin_width, margin_height ), expand = True )
            outpage.merge_page( inpage )

            # Write page to output
            pdf_writer.add_page( outpage )

            # If page number is odd add a blank page at the end
            if ( len( page_range ) % 2 ) == 1 and page_num == page_range[ -1 ] :
                outpage =  create_empty_page( inpage, margin_width, margin_height )
                pdf_writer.add_page( outpage )

        # Write output file
        with open( output_pdf, 'wb' ) as output_file:
            pdf_writer.write( output_file )            

def create_empty_page( inpage, margin_width, margin_height ) :
    return PyPDF2.PageObject.create_blank_page(
                width =  inpage.mediabox.width  + 2 * margin_width,  
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
    return [ i for i in range ( len( pdf_reader.pages ) ) if int( i ) not in skip_page_nos ]    


if __name__ == "__main__" :
    parser = argparse.ArgumentParser( prog = "pdf2book", description  = "Converts a PDF to book print format" )
    parser.add_argument( 'inpdf', help = "The input PDF" )
    parser.add_argument( 'outpdf', help = "The output PDF" )
    parser.add_argument( 'coverfrontpdf', nargs = '?', help = "The output cover front page PDF" )
    parser.add_argument( 'coverbackpdf', nargs = '?', help = "The output cover back page PDF" )
    parser.add_argument( '-W', '--margin_width',  help = "Margin width in mm", type = int, default = 3 )
    parser.add_argument( '-H', '--margin_height',  help = "Margin height in mm", type = int, default = 3 )
    parser.add_argument( '-P', '--skip_page',  help = "Skips the page with this number (starting from 0)", type = int, action = 'append', default = [] )
    args = parser.parse_args()

    add_margins( args.inpdf, args.outpdf, margin_width_mm = args.margin_width, margin_height_mm = args.margin_height, skip_page_nos = args.skip_page  )
    
    if args.coverfrontpdf :
        extract_page( args.inpdf, args.coverfrontpdf, 0 )
    if args.coverbackpdf :
        extract_page( args.inpdf, args.coverbackpdf, -1 )        
