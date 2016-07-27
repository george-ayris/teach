import numpy as np

class question():

	def __init__(self, **kwargs):

		self.qtype = kwargs.setdefault('qtype', 'question')

		self.number = 0
		self.explanation = 'Blank'
		self.diagram = None
		self.question = 'Blank'
		self.nested_list = []