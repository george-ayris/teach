import numpy as np
import pdb
import subprocess

import slate
import pdfminer
import pytesseract
from PIL import Image

import cairo

import qclass

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


def recurse_char(objs):

	charstr = []
	for obj in objs:
		if type(obj) is pdfminer.layout.LTChar:
			charstr += [ (obj.get_text(), obj.x0, obj.y0, obj.x1, obj.y1) ]
		else:
			try: 
				new_objs = obj._objs
				charstr += recurse_char(new_objs)
			except: 
				charstr += []

	return charstr # format x0,y0,x1,y1 



def get_questions(docstr):

	questions = []

	for ic, char in enumerate(docstr):
		#print char
		if char == '?':
			# Search back through string till beginning of sentence
			istart = 0 # Defaults to beginning of doc if can't find previous sentence
			for iback in range(ic-1,-1,-1):
				#pdb.set_trace()
				if docstr[iback] == '.' or docstr[iback] == '?' or docstr[iback] == '!':
					istart = int(iback)
					break

			new_q = qclass.question( question = docstr[istart+1:ic+1] )
			questions.append( new_q )

			#pdb.set_trace()

	return questions

def draw_page(charlist, width=612.0, height=792.0):

	surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, int(width), int(height))
	cr = cairo.Context(surface)
	cr.scale(width,height)

	cr.set_source_rgb(1.,1.,1.)
	#cr.rectangle(0,0,612,792)
	cr.rectangle(0,0,1,1)
	cr.fill()




	for char in charlist:
		cr.set_source_rgb(0.,0.,0.)
		cr.select_font_face("Georgia", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
		
		#cr.set_font_size( (char[4]-char[2])/ height )
		opts = cr.get_font_options()

		pdb.set_trace()

		cr.set_font_size( 0.5*( (char[3]-char[1])/ width + (char[4]-char[2])/ height) )

		cwidth, cheight = char[3]-char[1], char[4]-char[2]
		x_bearing, y_bearing, twidth, theight = cr.text_extents(char)[:4]
		cr.set_font_size(  )


		pdb.set_trace()

		cr.move_to( char[1]/width, 1-char[2]/height ) # Here coords are down from top left
		cr.show_text(char[0])


	surface.write_to_png('TestImage' + '.png')
	surface.finish()

	pdb.set_trace()

def main():

	#textstr = pytesseract.image_to_string(Image.open('units01.jpg'))
	#print textstr

	input_doc = './Examples/rationalnums.pdf'

	#with open(input_doc) as f: doc = slate.PDF(f)

	#num_pages = len(doc)
	#questions = get_questions(doc[1])
	#print doc[0]
	#print doc[1]

	layout = get_layout(input_doc)
	page = layout[0]
	#charlist = []
	charlist = recurse_char(page._objs)


	draw_page(charlist)

	pdb.set_trace()








if __name__ == "__main__":
	main()





