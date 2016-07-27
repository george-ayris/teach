import numpy as np

class question():

	def __init__(self, **kwargs):

		self.qtype = kwargs.setdefault('qtype', 'question')

		self.number = kwargs.setdefault('number', 0)
		self.explanation = kwargs.setdefault('explanation', ' ')
		self.diagram = kwargs.setdefault('diagaram', None)
		self.question = kwargs.setdefault('question', ' ')
		self.nested_list = []