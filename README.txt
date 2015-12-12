The PDFs I used were downloaded on September 25, 2015 from the NSA website where they were originally posted: https://www.nsa.gov/public_info/declass/cryptologs.shtml. Each file was hosted at https://www.nsa.gov/public_info/_files/cryptologs/<FILENAME>

The OCRed text files I used were downloaded on October 31, 2015 from http://cryptome.org/2013/03/cryptologs/00-cryptolog-index.htm (specifically http://cryptome.org/2013/03/nsa-cryptologs-txt.zip). Their text conversion seems to be better than the free one (xpdf pdftotext) that I tried, which smoothed columns together.

I used a basic stopwords list from http://www.ranks.nl/stopwords to which I added many Cryptolog-specific stopwords after some trial and error.

Data files generated using text2ldac python script (with some adaptations to ignore utf-8 decoding errors), originally from //github.com/JoKnopp/text2ldac

Documents sequenced into the following groups:
	26 (start to end of 1976)
	22 (1977-78)
	11 (1979-80)
	16 (1981-82)
	18 (1983-84)
	12 (1985-86)
	8 (1987-88)
	6 (1989-90)
	6 (1991-92)
	6 (1994-95)
	5 (1996-97)


I am hoping to turn this into an actual Ruby wrapper for DTM at some point.
