Class {
	#name : #BaselineOfCoverageBrowser,
	#superclass : #BaselineOf,
	#category : #BaselineOfCoverageBrowser
}

{ #category : #baselines }
BaselineOfCoverageBrowser >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec package: 'CoverageBrowser' ]
]
