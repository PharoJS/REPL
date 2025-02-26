"
I am a Server delegate used by WrServer to handle the actual requests.

I do all the actual work of the requests.

The current implementation of `evaluate:` is not sufficiently robust!
"
Class {
	#name : #WrFormServerDelegate,
	#superclass : #WrServerDelegate,
	#category : #'WebStREPL-Form'
}

{ #category : #'public access' }
WrFormServerDelegate >> evaluate: string [
	| output |
	output := String streamContents: [ :out | 
		[ 	| compiler result |
			compiler := [ self class compiler ] 
								on: MessageNotUnderstood 
								do: [ Smalltalk at: #Compiler "for Pharo 2.0" ].		
			result := compiler evaluate: string. 
			out print: result; cr ]
			on: Error
			do: [ :exception |
				out print: exception; cr.
				exception signalerContext printDetails: out.
				exception signalerContext sender debugStack: 8 on: out ].
		out cr ].
	^ String lf join: output lines
]

{ #category : #responses }
WrFormServerDelegate >> index: request html: html [
	| query |
	query := request uri queryAt: #q ifAbsent: [''].
	html
		tag: #p with: 'Type in any Smalltalk code, then hit the "Eval" button';
		tag: #form attributes: #(method 'GET') do: [
			html
				tag: #textarea attributes: #(id inputTextArea name q) with: query;
				tag: #button attributes: #(id evalButton) with: 'Eval';
				tag: #br; tag: #br.
				query isEmptyOrNil ifFalse: [
					html tag: #code with: (self evaluate: query)
				].
		]
]
