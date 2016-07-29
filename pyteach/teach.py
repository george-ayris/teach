import numpy as np
import pdb
import subprocess
import copy

import matplotlib.pyplot as plt

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
	charsy, candidates = [] ,[]
	for char in charsIN:	
		# Do not include whitespace characters
		try: 
			charstr = str(char[0])
			if not str(char[0]) == ' ':
				charsy.append(-char[2])
				candidates.append(char)
		except: 
			charsy.append(-char[2])
			candidates.append(char)

	inds = np.argsort(charsy)
	chars = [ candidates[inds[ic]] for ic in range(len(inds)) ]

	for char in chars:
		try: 
			charstr = str(char[0])
			if charstr == ' ': print 'YES'
		except:
			pass 

	# next sort into lines
	lines = []
	while chars:
		others = copy.copy(chars)
		char = chars[0]
		chars.remove(char)
		line = [char]
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


def groups_from_lines(lines, distance_lim=20):

	groups = [] # list of lists 

	## N.B. Current version does not make use of line position information!!!!!!!
	## The plan is to make use of this information to speed things up!
	n_lines = len(lines)
	to_group = [] # keep track of which candidates have been added to group
	to_group_line = []
	for il, line in enumerate(lines):
		for char in line: 
			to_group.append(char)
			to_group_line.append(il)
	ungrouped = copy.copy(to_group) # list of all candidates


	while ungrouped: # while there are still ungrouped characters

		group = [] # initialize new group

		# start with a non-grouped character
		char0 = ungrouped[0]

		# Keep track of which candidates have been compared with current group and which havent
		examined = []
		to_examine = [char0]

		# While there are members of the group who have not been examined
		while to_examine:

			# For each unexamined member of the group, find neighbours and add to group
			for char in to_examine:
				charx, chary = .5*(char[1]+char[3]), .5*(char[2]+char[4])

				# Find all neighbours of the current char and add to group
				# Only search ungrouped candidates
				distances = []
				for other in ungrouped:
					otherx, othery = .5*(other[1]+other[3]), .5*(other[2]+other[4])
					distances.append( np.sqrt( (otherx-charx)**2 + (othery-chary)**2 ) )
					if distances[-1] < distance_lim: # found a neighbour
						group.append(other) # move the candidate into the group


				# remove memebers of group from candidates for new searches
				ungrouped = list( set(ungrouped).difference(set(group))  ) 
				examined.append(char)
			

			# Update to_examine with any un examined members of the group	
			to_examine = list( set(group).difference( set(examined) ) )	

		# Remove members of group from overall characters
		for line in lines: line = list( set(line).difference( set(group) )  )

		# Add found group to overall list
		groups.append(group)

	return groups


def main():

	#textstr = pytesseract.image_to_string(Image.open('units01.jpg'))
	#print textstr

	input_doc = './Examples/romeojuliet.pdf'

	#with open(input_doc) as f: doc = slate.PDF(f)

	#num_pages = len(doc)
	#questions = get_questions(doc[1])
	#print doc[0]
	#print doc[1]

	layout = get_layout(input_doc)
	page = layout[0]

	chars = recurse_find(page._objs, pdfminer.layout.LTChar)
	images = recurse_find(page._objs, pdfminer.layout.LTFigure)

	lines = sort_into_lines(chars)

	groups = groups_from_lines(lines, distance_lim=20)

	for ig, group in enumerate(groups):
		print '\r\n Group no. ' + str(ig) + ' text:  \r\n'
		groupstr = ''
		for char in group:
			try: 
				charstr = str(char[0])
				groupstr += charstr
			except:
				pass
		print groupstr

	#pdb.set_trace()

	plt.figure()
	colorstr = ['b','r','g','y']
	colorstr += colorstr + colorstr + colorstr + colorstr + colorstr
	colorstr += colorstr + colorstr + colorstr + colorstr + colorstr
	for ig, group in enumerate(groups):
		for char in group:
			plt.scatter(char[1],char[2],c=colorstr[ig],lw=0)

	plt.show()

	#draw_page(chars)

	#pdb.set_trace()








if __name__ == "__main__":
	main()





