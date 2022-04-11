Class {
	#name : #DocumapsCoverageBrowser,
	#superclass : #CoverageBrowser,
	#category : #CoverageBrowser
}

{ #category : #accessing }
DocumapsCoverageBrowser >> methods [ 

 	 ^ 'Documaps Roassal Support' asPackage methods.
]

{ #category : #accessing }
DocumapsCoverageBrowser >> suite [ 

	^ 'Documaps Roassal Support-Tests' asPackage testSuite
]
