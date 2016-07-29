import numpy as np
import pdb
import subprocess
import copy

#import slate
import pdfminer
#import pytesseract
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


def sort_into_lines(charsIN, line_spacing=10):
	# sort as if you were reading from top left to bottom right

	# first sort the whole list by vertical distance 
	charsy = []
	for char in charsIN:	
		try: 
			charstr = str(char[0])
			if not str(char[0]) == ' ':
				charsy.append(-char[2])
		except: charsy.append(-char[2])

	inds = np.argsort(charsy)
	chars = [ charsIN[inds[ic]] for ic in range(len(inds)) ]

	# next sort into lines
	lines = []
	iline = 0
	while chars:
		others = copy.copy(chars)
		char = chars[0]
		chars.remove(char)
		line = [char]
		iline += 1
		print iline 
		for io, other in enumerate(others[1:]): 
			if abs(other[2] - char[2]) < line_spacing:
				line.append(other)
				chars.remove(other)

		# sort each line by x distance
		linex, _line = [], copy.copy(line)
		for linechar in line: 	linex.append(linechar[1])
		inds = np.argsort(np.array(linex))
		line = [ _line[inds[il]] for il in range(len(inds)) ]

		lines.append(line)

	return lines		

def groups_from_lines(linesIN, spacing_lim = 10):
	# with characters sorted into lines, we only need to search the same line,
	# then those above and below for neighbour candidates.


def find_groups(charsIN):

	chars = copy.copy(charsIN)

	lim = 10 # limit that neighbours can be in a group

	groups = [] # list of lists 

	while chars:

		others = copy.copy(chars)
		char = chars[0]

		charx, chary = .5*(char[1]+char[3]), .5*(char[2]+char[4])	

		distances, distx, disty = [], [], []
		for ic, other in enumerate(chars[1:]):
			try: 
				letter = str(other[0])
				if not letter == ' ':
					otherx, othery = .5*(other[1]+other[3]), .5*(other[2]+other[4])
					distx.append( abs(otherx-charx) )
					disty.append( abs(othery-chary) )
					distances.append( np.sqrt( (otherx-charx)**2 + (othery-chary)**2 ) )
			except: pass
		sortedi = np.argsort(np.array(distances))
		sortedd = np.array(distances)[sortedi]
		pdb.set_trace()

		group = [chars[0]]
		others.remove(chars[0])	
		bGroupFull = False
		while not bGroupFull:
			bGroupFull = True

			for member in group:
				memx, memy = .5*(member[1]+member[3]), .5*(member[2]+member[4])				
				for other in others:
					otherx, othery = .5*(other[1]+other[3]), .5*(other[2]+other[4])
					dist = np.sqrt( (otherx-memx)**2 + (othery-memy)**2 )
					if dist < lim: # found one to add to group
						group.append(other)
						others.remove(other)
						bGroupFull= False
						break
				if not bGroupFull:
					break


				print len(others)
		
		pdb.set_trace()

		groups.append(group) # add completed group to list
		for member in group: chars.remove(member) # remove group from candidates




	for group in groups:
		groupstr = ''
		for char in group:
			groupstr += str(char[0])
		pdb.set_trace()
		print groupstr + '\r\n'


	pdb.set_trace()

	return groups



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

	chars = recurse_find(page._objs, pdfminer.layout.LTChar)
	images = recurse_find(page._objs, pdfminer.layout.LTFigure)

	chars = sort_chars(chars)

	groups = find_groups(chars)

	draw_page(chars)

	pdb.set_trace()








if __name__ == "__main__":
	main()





