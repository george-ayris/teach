https://george-ayris.github.io/teach/

# Todo/Features
## GA
- Drag and drop (https://groups.google.com/forum/#!topic/elm-discuss/rGgAQkgOrt0)
- Nesting and un-nesting existing questions
- Editable header text at top of worksheet
- Images in question text
  - Appear in modal
  - Resize in question
  - Crop image on upload
  - Remove current image
- Question descriptions
- Print worksheets to pdf
- Register/login
- Save worksheet
- Tag worksheets/questions
- Question bank
- Search and then edit worksheets
- Diagram labelling
- Fill in the blank questions (with optional wordbank)
- Clone question
- Record question answers?

## LC
- Get text in correct order inside group
- Get group positions for ordering
- Decide whether group is a question or not

## Online questions
- Maths questions with working
- Colour questions?

# Bugs/Tech debt
- Max on number of sub questions
- Properly deal with limit to nesting in sub questions
- Switch on warn flag in compiler  
- Add more tests for existing features
- Extract shared webpack code
- Deal with pop up blocking of pdf render - probably display in a modal
- Use sass for the css

# Requirements  
- Python features currently require (working with Python 2.7):
- pdfminer - https://pypi.python.org/pypi/pdfminer
