Class {
	#name : #CoverageBrowser,
	#superclass : #SpPresenter,
	#instVars : [
		'trace',
		'methodsList',
		'codePresenter'
	],
	#category : #CoverageBrowser
}

{ #category : #'instance creation' }
CoverageBrowser class >> open [ 

	<script>
	self new open
]

{ #category : #'accessing - model' }
CoverageBrowser >> addHighlightsTo: aCodePresenter for: aMethod [

	| usedOffsets unusedOffsets allOffsets start end ranges codeRanges | 
	
	usedOffsets := trace at: aMethod ifAbsent: [ ^ self ].
	allOffsets := aMethod symbolicBytecodes collect: [ :each | each offset ].
	unusedOffsets := (allOffsets copyWithoutAll: usedOffsets) sorted.
	
	unusedOffsets ifEmpty: [ ^ self ].
	
	ranges := self continuousRangesFrom: unusedOffsets.
	
	codeRanges :=  self continuousRangesFrom: ((ranges flatCollect: [ :interval | 
		start := (aMethod rangeForPC: interval first) first.
		end := (aMethod rangeForPC: interval last) last.
		start to: end ]) asSet sorted).
		
	codeRanges do: [ :interval |
		aCodePresenter 
			addTextSegmentDecoration: (SpTextPresenterDecorator forHighlight
			interval: (interval first to: interval last + 1);
			yourself) ].	
	
	
]

{ #category : #'accessing - model' }
CoverageBrowser >> computeTrace [ 
 
	| testResult |
	trace := IdentityDictionary new.
	testResult := thisContext runSimulated: [self suite run] contextAtEachStep: [ :current |
        (trace at: current method ifAbsentPut: [ IdentitySet new ]) add: current pc ].
	^ testResult
]

{ #category : #'accessing - model' }
CoverageBrowser >> continuousRangesFrom: sortedIndexes [

	| result start last |
	
	result := OrderedCollection new.
	sortedIndexes ifEmpty: [ ^ result ].

	start := nil.
	sortedIndexes do: [ :index |
		start 
			ifNil: [ 
				start := index. 
				last := index ]
			ifNotNil: [ 
				index = (last + 1)
					ifFalse: [ 
						result add: (start to: last).
						start := index ].
				last := index  ] ].
		
	result add: (start to: sortedIndexes last).
		
	^ result
	
	

		
]

{ #category : #'accessing - model' }
CoverageBrowser >> coverageRatioFor: compiledMethod [

	^ trace
		  at: compiledMethod
		  ifPresent: [ :pcs | 
		  pcs size / compiledMethod symbolicBytecodes size * 100.0 ]
		  ifAbsent: [ 0.0 ]
]

{ #category : #'accessing - model' }
CoverageBrowser >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: methodsList;
		  add: codePresenter;
		  yourself
]

{ #category : #'accessing - model' }
CoverageBrowser >> filteredMethods [ 

	^ self methods reject: [ :aMethod | 
		self isIgnored: aMethod ]
]

{ #category : #'accessing - model' }
CoverageBrowser >> iconFor: compiledMethod [

	| ratio | 
	
	ratio := self coverageRatioFor: compiledMethod.
	
	ratio = 0 ifTrue: [ ^ self iconNamed: #testRed ].
	ratio = 100 ifTrue: [ ^ self iconNamed: #testGreen].

	^self iconNamed: #testYellow
]

{ #category : #'accessing - model' }
CoverageBrowser >> initialExtent [

	^ 900 @ 600
]

{ #category : #'accessing - model' }
CoverageBrowser >> initializePresenters [

	"self new openWithSpec"

	self computeTrace.
	
	methodsList := self newTable beResizable.
	codePresenter := self newCode.
	
	methodsList items: (self filteredMethods sorted: [ :a :b | a name <= b name ]).	

	methodsList addColumn:
		(SpStringTableColumn title: 'Class' evaluated: [ :cm |  cm methodClass ]).
	methodsList addColumn:
		(SpStringTableColumn title: 'Selector' evaluated: [ :cm | cm selector ]).
	methodsList addColumn: (SpStringTableColumn
			 title: 'Package'
			 evaluated: [ :cm | cm package name ]).
	methodsList addColumn: (SpImageTableColumn 
		evaluated: [ :cm | self iconFor: cm ]).
	methodsList addColumn: (SpStringTableColumn
			 title: 'Coverage [%]'
			 evaluated: [ :cm | self coverageRatioFor: cm ]).
	methodsList addColumn: (SpLinkTableColumn
			 title: 'Browse'
			 evaluated: [ :cm | 'browse' ]
			 action: [ :cm | cm browse ]).

	methodsList
		transmitTo: codePresenter
		transform: [ :cm | cm ifNil: [ '' ] ifNotNil: [ cm sourceCode ] ]
		postTransmission: [ :destination :origin :transmited | 
			transmited ifNotNil: [ 
				destination beForMethod: transmited.
				self addHighlightsTo: destination for: transmited	 ] ]
		
	
]

{ #category : #'accessing - model' }
CoverageBrowser >> isIgnored: aMethod [ 

	(aMethod hasPragmaNamed: #ignoreForCoverage)
		ifTrue: [ ^ true ].
		
	aMethod methodClass instanceSide isManifest 
		ifTrue: [ ^ true ].

	aMethod isSubclassResponsibility		
		ifTrue: [ ^ true ].

	aMethod isExplicitlyRequired		
		ifTrue: [ ^ true ].
		
	^ false 
]

{ #category : #'accessing - model' }
CoverageBrowser >> methods [ 

 	 ^ 'Text-Core' asPackage methods.
]

{ #category : #'accessing - model' }
CoverageBrowser >> suite [ 

	^ 'Text-Tests' asPackage testSuite
]

{ #category : #'accessing - model' }
CoverageBrowser >> title [

	^ 'Coverage Browser'
]
