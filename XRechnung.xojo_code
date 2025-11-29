#tag Class
Protected Class XRechnung
	#tag Method, Flags = &h0
		Sub Constructor()
		  Header = New InvoiceHeader
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DetectInvoiceFormat(xmlText As String) As String
		  If xmlText = "" Then Return "UNKNOWN"
		  
		  Var xml As String = xmlText.Trim
		  
		  ' ---- Detect UBL XRechnung ----
		  ' UBL namespace: urn:oasis:names:specification:ubl:schema:xsd:Invoice-2
		  If xml.IndexOf("urn:oasis:names:specification:ubl:schema:xsd:Invoice-2") >= 0 Then
		    Return "UBL"
		  End If
		  
		  ' Root element often: <Invoice ...>
		  If xml.Left(200).IndexOf("<Invoice") >= 0 Then
		    Return "UBL"
		  End If
		  
		  ' ---- Detect CII XRechnung ----
		  ' CII namespace: urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100
		  If xml.IndexOf("CrossIndustryInvoice") >= 0 Then
		    Return "CII"
		  End If
		  
		  ' Root element often: <rsm:CrossIndustryInvoice ...>
		  If xml.Left(200).IndexOf("CrossIndustryInvoice") >= 0 Then
		    Return "CII"
		  End If
		  
		  ' No matching XRechnung format found
		  Return "UNKNOWN"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExtractAttribute(xmlBlock As String, tagName As String, attributeName As String) As String
		  Var result As String = ""
		  
		  Try
		    Var rx As New RegEx
		    rx.SearchPattern = "<[^>]*" + tagName + "[^>]*" + attributeName + "=""([^""]*)"""
		    rx.Options.Greedy = False
		    Var m As RegExMatch = rx.Search(xmlBlock)
		    
		    If m <> Nil And m.SubExpressionCount > 1 Then
		      result = m.SubExpressionString(1)
		    End If
		    
		  Catch e As RuntimeException
		    // ignore or log
		  End Try
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExtractBlocksWithNS(xmlText As String, blockTag As String) As String()
		  Var results() As String
		  Var prefixes() As String = Array("", "cbc:", "cac:")
		  
		  For Each prefix As String In prefixes
		    Var startPos As Integer = 1
		    While startPos <= xmlText.Len
		      Var openTag As String = "<" + prefix + blockTag
		      Var closeTag As String = "</" + prefix + blockTag + ">"
		      Dim s As Integer = xmlText.InStr(startPos, openTag)
		      If s = 0 Then Exit
		      Dim e As Integer = xmlText.InStr(s, closeTag)
		      If e = 0 Then Exit
		      results.Add(xmlText.Mid(s, e + closeTag.Len - s))
		      startPos = e + closeTag.Len
		    Wend
		  Next
		  
		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExtractFirstTag(xmlText As String, tagName As String) As String
		  Return ExtractTagFromBlockWithNS(xmlText, tagName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExtractTagFromBlockWithNS(blockContent As String, tagName As String) As String
		  // Search for <anyprefix:tagName> or <tagName>
		  Var prefixes() As String = Array("", "cbc:", "cac:")
		  
		  For Each prefix As String In prefixes
		    Var startTag As String = "<" + prefix + tagName
		    Var endTag As String = "</" + prefix + tagName + ">"
		    
		    Var startPos As Integer = blockContent.InStr(startTag)
		    If startPos > 0 Then
		      startPos = blockContent.InStr(startPos, ">") + 1
		      Var endPos As Integer = blockContent.InStr(startPos, endTag)
		      If startPos > 0 And endPos > 0 Then
		        Return blockContent.Mid(startPos, endPos - startPos).Trim
		      End If
		    End If
		  Next
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GenerateInvoicePDF(pdfFile As FolderItem)
		  ' Create PDF
		  Var pdf As New PDFDocument(PDFDocument.PageSizes.A4)
		  Var g As PDFGraphics = pdf.Graphics
		  g.FontName = PDFDocument.StandardFontNames.LiberationSans
		  g.FontSize = 12
		  
		  Var marginLeft As Double = 40
		  Var marginTop As Double = 40
		  Var pageWidth As Double = pdf.PageWidth
		  Var pageHeight As Double = pdf.PageHeight
		  Var y As Double = marginTop
		  
		  Var docTypes As New Dictionary 
		  docTypes.Value("326") = "Teilrechnung"
		  docTypes.Value("380") = "Handelsrechnung"
		  docTypes.Value("384") = "Rechnungskorrektur"
		  docTypes.Value("389") = "Selbst ausgestellte Rechnung"
		  
		  ' Back Color
		  g.DrawingColor = &cB0D6FF00
		  g.FillRectangle(35, 110, 235, 90) // Buyer
		  g.FillRectangle(295, 110, 235, 90) // Supplier
		  
		  
		  ' Title
		  g.DrawingColor = Color.Black
		  g.FontSize = 18
		  g.Bold = True
		  If docTypes.HasKey(Header.InvoiceTypeCode) Then
		    g.DrawText(docTypes.Value(Header.InvoiceTypeCode), marginLeft, y)  
		  Else
		    g.DrawText("Unbekannt", marginLeft, y) 
		  End If
		  g.Bold = False
		  y = y + 30
		  
		  ' Header
		  g.FontSize = 10
		  g.DrawText("Invoice Number: " + Header.InvoiceNumber, marginLeft, y)
		  y = y + 15
		  g.DrawText("Date: " + Header.InvoiceDate, marginLeft, y)
		  y = y + 15
		  g.DrawText("Currency: " + Header.CurrencyCode, marginLeft, y)
		  y = y + 20
		  
		  
		  ' Buyer block
		  Var customerX As Double = marginLeft
		  Var customerY As Double = marginTop + 85
		  g.FontSize = 12
		  g.Bold = True
		  g.DrawText("Buyer", customerX, customerY)
		  g.FontSize = 10
		  g.Bold = False
		  customerY = customerY + 15
		  g.DrawText(Header.customerName, customerX, customerY)
		  customerY = customerY + 12
		  g.DrawText(Header.customerStreet, customerX, customerY)
		  customerY = customerY + 12
		  g.DrawText(Header.customerZip + " " + Header.customerCity.Trim, customerX, customerY)
		  'customerY = customerY + 12 
		  'g.DrawText("Tel: " + Header.CustomerPhone, customerX, customerY)
		  'customerY = customerY + 12 
		  'g.DrawText("Mail: " + Header.CustomerMail, customerX, customerY)
		  
		  ' Supplier block
		  Var sellerX As Double = pageWidth / 2
		  Var sellerY As Double = marginTop + 85
		  g.FontSize = 12
		  g.Bold = True
		  g.DrawText("Supplier", sellerX, sellerY)
		  g.FontSize = 10
		  g.Bold = False
		  sellerY = sellerY + 15
		  g.DrawText(Header.SupplierName, sellerX, sellerY)
		  sellerY = sellerY + 12
		  g.DrawText(Header.SupplierStreet, sellerX, sellerY)
		  sellerY = sellerY + 12
		  g.DrawText(Header.SupplierZip + " " + Header.SupplierCity.Trim, sellerX, sellerY)
		  If Header.SupplierPhone <> "" Then 
		    sellerY = sellerY + 12
		    g.DrawText("Phone: " + Header.SupplierPhone, sellerX, sellerY)
		  End If
		  If Header.SupplierMail <> "" Then 
		    sellerY = sellerY + 12
		    g.DrawText("Mail: " + Header.SupplierMail, sellerX, sellerY)
		  End If
		  
		  y = margintop + 200
		  
		  ' Table header
		  g.FontSize = 11
		  g.Bold = True
		  g.DrawText("Description", marginLeft, y)
		  g.DrawText("Qty", 250, y)
		  'g.DrawText("Unit", pageWidth - 220, y)
		  g.DrawText("Price", 330, y)
		  g.DrawText("VAT %", pageWidth - 145, y)
		  g.DrawText("Amount", pageWidth - 90, y)
		  g.Bold = False
		  y = y + 10
		  g.DrawLine(marginLeft, y, pageWidth - 35, y)
		  y = y + 15
		  
		  ' Table rows
		  For Each l As InvoiceLine In Lines
		    g.DrawText(l.Description, marginLeft, y)
		    'g.DrawText(l.Quantity + " " + l.UnitCode, 250, y)
		    g.DrawText(l.Quantity, 250, y)
		    g.DrawText(Format(Val(l.Price), "0.0000") + " " + Header.CurrencyCode, 330, y)
		    g.DrawText(l.VatPercent, pageWidth - 140, y)
		    g.DrawText(Format(Val(l.Amount), "0.00"),pageWidth -90, y)
		    'g.DrawText(Header.TotalAmount + " " + Header.CurrencyCode, 450, y)
		    y = y + 18
		  Next
		  
		  
		  ' Total
		  g.DrawLine(marginLeft, y, pageWidth - 35, y)
		  y = y + 20
		  g.FontSize = 12
		  g.Bold = True
		  g.DrawText("Amount:",pageWidth - 230, y)
		  g.DrawText(Format(Val(Header.TaxExclusiveAmount), "0.00") + " " + Header.CurrencyCode, pageWidth - 120, y)
		  y = y + 15
		  g.DrawText("Total Amount:" , pageWidth - 230, y)
		  g.DrawText(Format(Val(Header.TaxInclusiveAmount), "0.00") + " " + Header.CurrencyCode, pageWidth - 120, y)
		  y = y + 20
		  g.DrawText("Prepaid Amount:", pageWidth - 230, y)
		  g.DrawText(Format(Val(Header.PrepaidAmount), "-0.00") + " " + Header.CurrencyCode, pageWidth - 120, y)
		  y = y + 15
		  g.DrawText("Payable Amount:", pageWidth - 230, y)
		  g.DrawText(Format(Val(Header.PayableAmount), "-0.00") + " " + Header.CurrencyCode, pageWidth - 120, y)
		  g.Bold = False
		  
		  g.FontSize = 10
		  y = y + 45
		  g.DrawText("Payment Terms: " + Header.PaymentNote, marginLeft, y)
		  y = y + 25
		  g.DrawText("Payment ID: " + Header.PaymentID, marginLeft, y)
		  
		  ' Save PDF
		  Try
		    pdf.Save(pdfFile)
		    'MessageBox("PDF successfully created.")
		  Catch err As IOException
		    MessageBox("Unable to save PDF: " + err.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LoadXML(xmlText As String) As Boolean
		  
		  Self.Format = DetectInvoiceFormat(xmlText)
		  
		  Select Case Self.Format
		    
		  Case "UBL"
		    ParseUBL(xmlText)
		    Return True
		    
		  Case "CII"
		    MessageBox("CII detected. Currently only UBL is supported.")
		    Return False
		    
		  Case Else
		    MessageBox("This file is not a valid XRechnung (UBL or CII).")
		    Return False
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParseUBL(xmlText As String)
		  
		  Header.InvoiceNumber = ExtractFirstTag(xmlText, "ID")
		  Header.InvoiceDate = ExtractFirstTag(xmlText, "IssueDate")
		  Header.InvoiceTypeCode = ExtractFirstTag(xmlText, "InvoiceTypeCode")
		  Header.CurrencyCode = ExtractFirstTag(xmlText, "DocumentCurrencyCode")
		  Header.PaymentNote = ExtractFirstTag(xmlText, "Note")
		  
		  Header.TaxExclusiveAmount = ExtractFirstTag(xmlText, "TaxExclusiveAmount")
		  Header.TaxInclusiveAmount = ExtractFirstTag(xmlText, "TaxInclusiveAmount")
		  Header.PrepaidAmount = ExtractFirstTag(xmlText, "PrepaidAmount")
		  Header.PayableAmount = ExtractFirstTag(xmlText, "PayableAmount")
		  
		  ' Supplier
		  Var supBlocks() As String = ExtractBlocksWithNS(xmlText, "AccountingSupplierParty")
		  If supBlocks.Ubound >= 0 Then
		    Var b As String = supBlocks(0)
		    Header.SupplierName = ExtractTagFromBlockWithNS(b, "Name")
		    Header.SupplierStreet = ExtractTagFromBlockWithNS(b, "StreetName")
		    Header.SupplierZip = ExtractTagFromBlockWithNS(b, "PostalZone")
		    Header.SupplierCity = ExtractTagFromBlockWithNS(b, "CityName")
		    Header.SupplierPhone = ExtractTagFromBlockWithNS(b, "Telephone")
		    Header.SupplierMail = ExtractTagFromBlockWithNS(b, "ElectronicMail")
		  End If
		  
		  ' Customer
		  Var cusBlocks() As String = ExtractBlocksWithNS(xmlText, "AccountingCustomerParty")
		  If cusBlocks.Ubound >= 0 Then
		    Var b As String = cusBlocks(0)
		    Header.CustomerName = ExtractTagFromBlockWithNS(b, "RegistrationName")
		    Header.CustomerStreet = ExtractTagFromBlockWithNS(b, "StreetName")
		    Header.CustomerZip = ExtractTagFromBlockWithNS(b, "PostalZone")
		    Header.CustomerCity = ExtractTagFromBlockWithNS(b, "CityName")
		  End If
		  
		  ' Invoice lines
		  Var lineBlocks() As String = ExtractBlocksWithNS(xmlText, "InvoiceLine")
		  ReDim Lines(-1)
		  
		  For Each block As String In lineBlocks
		    Var ln As New InvoiceLine
		    
		    ln.ID = ExtractTagFromBlockWithNS(block, "ID")
		    ln.Description = ExtractTagFromBlockWithNS(block, "Name")
		    ln.Quantity = ExtractTagFromBlockWithNS(block, "InvoicedQuantity")
		    ln.UnitCode = ExtractAttribute(block, "InvoicedQuantity", "unitCode")
		    ln.Price = ExtractTagFromBlockWithNS(block, "PriceAmount")
		    ln.Amount = ExtractTagFromBlockWithNS(block, "LineExtensionAmount")
		    ln.VatPercent = ExtractTagFromBlockWithNS(block, "Percent")
		    
		    Lines.Add(ln)
		  Next
		  
		End Sub
	#tag EndMethod


	#tag Note, Name = ReadMe
		Xojo XRechnung Class - Developed by Wolfgang Schwarz, Germany
		
		Class for converting an XRechnung XML file into a readable PDF
		
		Written in Xojo (https://www.xojo.com)
		
		
		Commands:
		
		LoadXML(xmlText As String)
		 |
		 |_ DetectInvoiceFormat(xmlText As String) 
		 |
		 |_ ParseUBL(xmlText As String) 
		
		GenerateInvoicePDF(file As FolderItem)
		
		
		For more information, visit: https://github.com/woschwarz
		
	#tag EndNote

	#tag Note, Name = ToDo
		- Add parsing of the CII format 
		- Multilingual Support
		
	#tag EndNote


	#tag Property, Flags = &h0
		Format As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Header As InvoiceHeader
	#tag EndProperty

	#tag Property, Flags = &h0
		Lines() As InvoiceLine
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
			Name="Format"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Header"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
