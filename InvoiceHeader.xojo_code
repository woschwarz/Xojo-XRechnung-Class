#tag Class
Protected Class InvoiceHeader
	#tag Property, Flags = &h0
		CurrencyCode As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CustomerCity As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CustomerName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CustomerStreet As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CustomerZip As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InvoiceDate As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InvoiceNumber As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InvoiceTypeCode As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PayableAmount As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PaymentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PaymentNote As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PrepaidAmount As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SupplierCity As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SupplierMail As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SupplierName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SupplierPhone As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SupplierStreet As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SupplierZip As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TaxExclusiveAmount As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TaxInclusiveAmount As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="InvoiceNumber"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
