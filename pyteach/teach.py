import numpy as np
import pdb
import subprocess
import copy
import matplotlib.pyplot as plt
import os

import sys
sys.path.insert(0, os.getenv("HOME") + '/teach/Examples/') 
sys.path.insert(0, os.getenv("HOME") + '/phd-code/utils/')

import utilities as utils

#import slate
import pdfminer
#import pytesseract
from PIL import Image

import page_analysis as pa
import pdf_scanner as ps

import optparse

def main():

	parser = optparse.OptionParser()
	options, args = parser.parse_args()

	try:	filename = str(args[0])
	except: raise "Input must be string!"

	base_dir = os.getenv("HOME")
	input_doc = base_dir + '/teach/Examples/' + filename


	#textstr = pytesseract.image_to_string(Image.open('units01.jpg'))
	#print textstr

	#with open(input_doc) as f: doc = slate.PDF(f)

	#num_pages = len(doc)
	#questions = get_questions(doc[1])
	#print doc[0]
	#print doc[1]

	layout = ps.get_layout(input_doc)
	page = layout[0]

	_chars = ps.recurse_find(page._objs, pdfminer.layout.LTChar)
	_images = ps.recurse_find(page._objs, pdfminer.layout.LTFigure)

	# convert chars into pa.char objects
	#chars = []
	#for char in _chars: 
	#	chars.append( pa.char(	text=char[0], x0=char[1],y0=char[2],
	#							x1=char[3], y1=char[4]) )
	#lines = pa.sort_into_lines(chars)
	
	lines = pa.sort_into_lines(_chars, ctype = 'tuple')
	groups = pa.groups_from_lines(lines, distance_lim=20, ctype='tuple')

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

	#utils.mpl2tex()

	plt.figure()
	colorstr = ['b','r','g','y','m','k','c']
	colorstr += colorstr + colorstr + colorstr + colorstr + colorstr
	colorstr += colorstr + colorstr + colorstr + colorstr + colorstr
	for ig, group in enumerate(groups):
		cstr = colorstr[ig]
		for char in group:
			plt.scatter(char[1],char[2],c=cstr,lw=0)

	plt.show()

	#draw_page(chars)

	#pdb.set_trace()








if __name__ == "__main__":
	

	main()





