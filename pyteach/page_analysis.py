
import numpy as np
import pdb
import subprocess
import copy
import time

class char():
	def __init__(self, **kwargs):
		self.text = kwargs.setdefault('text',' ')
		self.x0 = kwargs.setdefault('x0', 0.)
		self.x1 = kwargs.setdefault('x1', 0.)
		self.y0 = kwargs.setdefault('y0', 0.)
		self.y1 = kwargs.setdefault('y1', 0.)
		self.line_no = kwargs.setdefault('line_no', 0)

def sort_into_lines(charsIN, line_spacing=10, ctype='obj'):
	''' sort as if you were reading from top left to bottom right.
	Returns a list of lines, each line is sorted from left to right '''

	# first sort the whole list by vertical distance 
	charsy, candidates = [] ,[]
	for char in charsIN:	
		# Do not include whitespace characters
		if ctype == 'tuple': chary0 = char[2]
		else:				 chary0 = char.y0
		try: 
			charstr = str(char.text)
			if not str(char.text) == ' ':
				charsy.append(-chary0)
				candidates.append(char)
		except: 
			charsy.append(-chary0)
			candidates.append(char)

	inds = np.argsort(charsy)
	chars = [ candidates[inds[ic]] for ic in range(len(inds)) ]


	# next sort into lines
	lines, iline = [], 0 # lines entries have an extry term to say what line they're on
	while chars:
		others = copy.copy(chars)
		char = chars[0]
		chars.remove(char)		
		if ctype=='tuple': 	char += (iline,)
		else: 				char.line_no = iline
		line = [char]
		for io, other in enumerate(others[1:]): 
			if ctype == 'tuple': othery0, chary0 = other[2], char[2]
			else:				 othery0, chary0 = other.y0, char.y0
			if abs(othery0 - chary0) < line_spacing:
				chars.remove(other)
				if ctype=='tuple': 	other += (iline,)
				else: 				other.line_no = iline			
				line.append(other)

		# also sort each line by x distance
		linex, _line = [], copy.copy(line)
		for linechar in line: 	
			if ctype=='tuple': 	linex.append(linechar[1])
			else: 				linex.append(linechar.x0)
			
		inds = np.argsort(np.array(linex))
		line = [ _line[inds[il]] for il in range(len(inds)) ]

		lines.append(line)
		iline += 1

	return lines		


def groups_from_lines(lines, distance_lim=20, ctype='obj'):

	t0 = time.time()

	''' Sorts a list of lines for the whole page into groups of text.
	Returns a list of groups, each group is ordered for reading '''

	groups = [] # list of lists 

	## Keep line structure to make use of the information
	n_lines = len(lines)
	to_group = [] # keep track of which candidates have been added to group
	for line in lines:
		for char in line: 
			to_group.append(char)
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
				if ctype=='tuple':	charx, chary = .5*(char[1]+char[3]), .5*(char[2]+char[4])
				else:				charx, chary = .5*(char.x0+char.x1), .5*(char.y0+char.y1)

				# Find all neighbours of the current char and add to group
				# Only search ungrouped candidates whcih are in adjacent lines
				candidates = []
				if ctype=='tuple': iline = char[5]
				else:			  iline = char.line_no
				candidates += lines[iline]
				if iline != 0: 			candidates += lines[iline-1]
				if iline != n_lines-1: 	candidates += lines[iline+1]

				to_search = list( set(ungrouped).intersection(set(candidates)) )

				distances = []
				for other in to_search:
					if ctype=='tuple':   otherx, othery = .5*(other[1]+other[3]), .5*(other[2]+other[4])
					else: 				otherx, othery = .5*(other.x0+other.x1), .5*(other.y0+other.y1)
					
					# measure distance as smallest distance between corners
					#distance1 = np.sqrt((other[1]-char[1])**2 + (other[3]-char[3])**2)
					#distance2 = np.sqrt((other[1]-char[1])**2 + (other[3]-char[3])**2)

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



	# Now sort each of the group's text into order
	new_groups = []
	for group in groups:
		glines = sort_into_lines(group, ctype=ctype)
		# now sort lines by height
		heights = []
		for line in glines:
			if ctype=='tuple':	heights.append(line[0][2])
			else:				heights.append(line[0].y0)
		inds = np.argsort(np.array(heights))[-1::-1]
		sglines = [glines[ind] for ind in inds] # sorted by height

		ordered_group = []
		for gline in sglines: ordered_group += gline
		new_groups.append(ordered_group)

	# Now sort all groups by height order (using the first char as reference)
	#heights = []
	#for group in new_groups: heights.append(group[0][])

	t1 = time.time()
	print 'Time to group: ' + str(t1-t0)
	pdb.set_trace()

	return new_groups