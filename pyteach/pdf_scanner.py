#import slate
import pdfminer
#import pytesseract
from PIL import Image

import cairo

from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.converter import TextConverter, PDFPageAggregator
from pdfminer.layout import LAParams
from pdfminer.pdfpage import PDFPage

from cStringIO import StringIO

def convert_pdf_to_txt(path): 
	## TAKEN FROM STACK OVERFLOW
	## see... http://www.unixuser.org/~euske/python/pdfminer/programming.html for tutorial
	## Also see... https://github.com/dpapathanasiou/pdfminer-layout-scanner/blob/master/layout_scanner.py
	rsrcmgr = PDFResourceManager()
	retstr = StringIO()
	codec = 'utf-8'
	laparams = LAParams()

	fp = file(path, 'rb')
	password = ""
	maxpages = 0
	caching = True
	pagenos=set()

	# Read text from pages
	device = TextConverter(rsrcmgr, retstr, codec=codec, laparams=laparams)	
	interpreter = PDFPageInterpreter(rsrcmgr, device)	
	for page in PDFPage.get_pages(fp, pagenos, maxpages=maxpages, password=password,caching=caching, check_extractable=True):
		interpreter.process_page(page)
	str = retstr.getvalue()

	fp.close()
	device.close()
	retstr.close()

	return str


def get_layout(path):
	'''returns a list of every character in the document as well as its location'''

	rsrcmgr = PDFResourceManager()
	retstr = StringIO()
	codec = 'utf-8'
	laparams = LAParams()

	fp = file(path, 'rb')
	password = ""
	maxpages = 0
	caching = True
	pagenos=set()

	layout = []
	device = PDFPageAggregator(rsrcmgr, laparams=laparams)
	interpreter = PDFPageInterpreter(rsrcmgr, device)
	for page in PDFPage.get_pages(fp, pagenos, maxpages=maxpages, password=password,caching=caching, check_extractable=True):
		interpreter.process_page(page)
		layout.append(  device.get_result()  )
	fp.close()
	device.close()
	retstr.close()

	return layout


def recurse_find(objs, target_obj=pdfminer.layout.LTChar):

	returnlist = []
	for obj in objs:

		try: 
			new_objs = obj._objs
			returnlist += recurse_find(new_objs, target_obj)

		except: 

			# If no more recursion can occur
			if type(obj) is target_obj:

				if target_obj == pdfminer.layout.LTChar:
					returnlist += [ (obj.get_text(), obj.x0, obj.y0, obj.x1, obj.y1) ]
				elif target_obj == pdfminer.layout.LTFigure:
					pdb.set_trace()

	return returnlist # format x0,y0,x1,y1 



def draw_page(charlist, width=612.0, height=792.0):

	surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, int(width), int(height))
	cr = cairo.Context(surface)
	cr.scale(width,height)

	cr.set_source_rgb(1.,1.,1.)
	#cr.rectangle(0,0,612,792)
	cr.rectangle(0,0,1,1)
	cr.fill()


	cr.set_source_rgb(0.,0.,0.)
	cr.select_font_face("Georgia", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
		
	for char in charlist:
		c = str(char[0])
		if c=='a' or c=='e' or c=='o' or c=='u':
			cr.set_font_size( (char[4]-char[2])/ height )
			break


	for char in charlist:

		#cwidth, cheight = char[3]-char[1], char[4]-char[2]
		#x_bearing, y_bearing, twidth, theight = cr.text_extents(str('a'))[:4]

		cr.move_to( char[1]/width, 1-char[2]/height ) # Here coords are down from top left
		cr.show_text(char[0])


	surface.write_to_png('TestImage' + '.png')
	surface.finish()

