; Script created by Elise Windbloom

#include <Array.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <Date.au3>

Global $sVMDConverterDir = @ScriptDir & "\VMDConverter\VMDConverter.exe"
Global $vmdFile = FileOpenDialog("Select VMD File (with mouth data only) to clean and optimize", @ScriptDir, "VMD Files (*.vmd);;All Files (*.*)", 1)
If @error Then
   MsgBox(0, "", "No vmd file was selected."); Display the error message.
   Exit
EndIf
; Get the start time
Global $startTime = TimerInit() ;entire process
Global $startTimeCleanData, $elapsedTimeStringCleanData ;time to just clean the data

;Load CSV file
ToolTip("Converting to CSV file")
Sleep(1000)
ToolTip("")
Global $csvFile = _RunVMDConverter($vmdFile);convert to csv file
ToolTip("Cleaning/Optimizing CSV file")
Sleep(1000)
ToolTip("")
Global $cArray = _LoadCSV($csvFile)
Global $cArrayFinal[0][0]


; TEST - Let's say you want to read and display the item in the second row and third column
;Local $rowIndex = 1 ; Rows are zero-based, so 1 corresponds to the second row
;Local $colIndex = 2 ; Columns are zero-based, so 2 corresponds to the third column
;ConsoleWrite("Item at Row " & $rowIndex & ", Column " & $colIndex & ": " & $cArray[$rowIndex][$colIndex] & @CRLF)
;_ArrayDisplay($cArray, "CSV Array After Removing First Column")


;===
$startTimeCleanData = TimerInit()
Global $csvFileCleaned = _CleanData()
$elapsedTimeStringCleanData = _GetElapsedTime($startTimeCleanData, 0)
ToolTip("Saving cleaned VMD file")
Sleep(1000)
ToolTip("")
Global $vmdFileCleaned = _RunVMDConverter($csvFileCleaned);convert back to final vmd file
FileDelete($csvFile)
FileDelete($csvFileCleaned)
;ToolTip("")
Global $elapsedTimeString = _GetElapsedTime($startTime, 0)
MsgBox(0, "Complete", "Time Taken (Cleaning Data Only): " & $elapsedTimeStringCleanData & @CRLF & "Time Taken (Total): " & $elapsedTimeString & @CRLF & @CRLF & "Cleaned VMD file saved:" & @CRLF & $vmdFileCleaned)


;==========================Functions
Func _RunVMDConverter($fileDir)
   ;run VMD Converter to convert file vmd to csv OR csv to vmd
   ;$fileDir should either be a vmd or csv file
   ;returns newly created filename with full diretory
   RunWait(@ComSpec & ' /c ""' & $sVMDConverterDir & '" "' & $fileDir & '""', "", @SW_HIDE)

   ;return new file name
   Local $newFile = ""
   If _GetFileExtension($fileDir) == "vmd" Then
	  $newFile = _GetFileDirectory($fileDir) & "\" & _GetFileNameWithoutExtension($fileDir) & ".csv"
   Else
	  $newFile = _GetFileDirectory($fileDir) & "\" & _GetFileNameWithoutExtension($fileDir) & ".vmd"
   EndIf

   If FileExists($newFile) Then
	  Return $newFile
   Else
	  MsgBox(0, "Error - File Not Found", $newFile & " not found.")
	  Exit
   EndIf
EndFunc

Func _CleanData()
    ; Initialize the array size and pre-allocate arrays with the size of the entire cArray
    Local $arraySize = UBound($cArray)
    Local $iCount = 0
    Local $aIndexA[$arraySize], $aIndexI[$arraySize], $aIndexU[$arraySize], $aIndexO[$arraySize], $aIndexExtra[$arraySize]
    Local $iA = 0, $iI = 0, $iU = 0, $iO = 0, $iExtra = 0

    ; Loop through the first column of the array to find the starting index and populate arrays
    Local $iStartIndex = -1
    For $i = 0 To $arraySize - 1
        If $iStartIndex == -1 Then
            _AddRowTo2DArray($cArrayFinal, $cArray, $i)
            If StringInStr("あいうお", $cArray[$i][0]) Then
                $iStartIndex = $i
            EndIf
        Else
            Switch $cArray[$i][0]
                Case "あ"
                    $aIndexA[$iA] = $i
                    $iA += 1
                Case "い"
                    $aIndexI[$iI] = $i
                    $iI += 1
                Case "う"
                    $aIndexU[$iU] = $i
                    $iU += 1
                Case "お"
                    $aIndexO[$iO] = $i
                    $iO += 1
                Case Else
                    If $i > $iStartIndex Then
                        $aIndexExtra[$iExtra] = $i
                        $iExtra += 1
                    EndIf
            EndSwitch
        EndIf
    Next

    ; Resize the arrays to the exact number of elements added
    ReDim $aIndexA[$iA], $aIndexI[$iI], $aIndexU[$iU], $aIndexO[$iO], $aIndexExtra[$iExtra]

    ProcessIndexes($aIndexA, $cArray, $cArrayFinal, $iCount)
    ProcessIndexes($aIndexI, $cArray, $cArrayFinal, $iCount)
    ProcessIndexes($aIndexU, $cArray, $cArrayFinal, $iCount)
    ProcessIndexes($aIndexO, $cArray, $cArrayFinal, $iCount)

    For $i = 0 To UBound($aIndexExtra) - 1
        _AddRowTo2DArray($cArrayFinal, $cArray, $aIndexExtra[$i])
    Next

    $cArrayFinal[$iStartIndex - 1][0] = String($iCount + 1)
    ConsoleWrite("Array Item at Row " & ($iStartIndex - 1) & ", Column " & 0 & ": " & $cArray[$iStartIndex - 1][0] & " $iCount=" & $iCount & @CRLF)

    ; Export the array to a CSV file
    ExportArrayToCSV($cArrayFinal, _GetFileDirectory($csvFile) & "\" & _GetFileNameWithoutExtension($csvFile) & "_cleaned.csv")
    Return _GetFileDirectory($csvFile) & "\" & _GetFileNameWithoutExtension($csvFile) & "_cleaned.csv"
EndFunc

Func ProcessIndexes(ByRef $aIndexes, ByRef $cArray, ByRef $cArrayFinal, ByRef $iCount)
    For $j = 0 To UBound($aIndexes) - 1
        If $j < 2 Or $j > (UBound($aIndexes) - 3) Then
            $iCount += 1
            _AddRowTo2DArray($cArrayFinal, $cArray, $aIndexes[$j])
        Else
            Local $v1 = Number($cArray[$aIndexes[$j]][2])
            Local $v2 = Number($cArray[$aIndexes[$j - 1]][2])
            Local $v3 = Number($cArray[$aIndexes[$j + 1]][2])
            If Not ($v1 == 0 And $v2 == 0 And $v3 == 0) And _HigherOrLower($v1, $v2, $v3) Then
                $iCount += 1
                _AddRowTo2DArray($cArrayFinal, $cArray, $aIndexes[$j])
            EndIf
        EndIf
    Next
EndFunc


Func _LoadCSV($csvFile)
   ; Code to read CSV into a 2D array

   If Not @error Then
	  Global $csvData = FileRead($csvFile)
	  Global $lines = StringSplit($csvData, @CRLF, 1+2)
	  Global $maxColumns = 0

	  For $i = 0 To UBound($lines) - 1
		 $numColumns = StringSplit($lines[$i], ",")
		 $maxColumns = ($maxColumns > UBound($numColumns)) ? $maxColumns : UBound($numColumns)
	  Next

	  Global $csvArray[UBound($lines)][$maxColumns]

	  For $i = 0 To UBound($lines) - 1
		 $values = StringSplit($lines[$i], ",")
		 For $j = 0 To UBound($values) - 1
			$csvArray[$i][$j] = $values[$j]
		 Next
	  Next

	  ; Display the original array
	  ;_ArrayDisplay($csvArray, "Original CSV Array")

	  ; Create a new array without the first column
	  Local $newArray[UBound($lines)][UBound($csvArray, 2) - 1]

	  ; Copy values from the original array to the new array, excluding the first column
	  For $i = 0 To UBound($csvArray) - 1
		 For $j = 1 To UBound($csvArray, 2) - 1
			$newArray[$i][$j - 1] = $csvArray[$i][$j]
		 Next
	  Next

	  ; Display the array after removing the first column
	  ;_ArrayDisplay($newArray, "CSV Array After Removing First Column")
	  Return $newArray

   Else
	   MsgBox(16, "Error", "No file selected.")
   EndIf
EndFunc

Func _HigherOrLower($v1,$v2,$v3)
   ;returns True if v1 is lager than both v2 and v3
   ;returns True if v1 is smaller than both v2 and v3
   ;otherwise return False
   ;$v1 = Number($v1)
   ;$v2 = Number($v2)
   ;$v3 = Number($v3)
   ;$v4 = Number($v4)
   If $v1 > $v2 And $v1 > $v3 Then;largest
	  Return True
   ElseIf $v1 < $v2 And $v1 < $v3 Then;smallest
	  Return True
   ElseIf $v1 == 0 And ($v2 <> 0 Or $v3 <> 0) Then;only zero
	  Return True
   ElseIf $v1 == 1 And ($v2 <> 1 Or $v3 <> 1) Then;only one
	  Return True
   ElseIf $v1 < 0.0099 And (($v2 > 0.0099 And $v2 > $v1) Or ($v3 > 0.0099 And $v3 > $v1)) Then
	  ;tries to get the moment when mouth close gets very small (basically closed it's so small)
	  Return True
   Else;neither largest or smallest
	  Return False
   EndIf
EndFunc

;adds a chosen row from a 2D array to another 2D array
Func _AddRowTo2DArray(ByRef $destinationArray, $sourceArray, $sourceRowIndex)
   ; Check if $destinationArray is not a 2D array
   If UBound($destinationArray, 0) <> 2 Then
	  MsgBox(16, "Error", "$destinationArray is not a 2D array.")
	  Return
   EndIf

   ; Check if $sourceArray is not a 2D array
   If UBound($sourceArray, 0) <> 2 Then
	  MsgBox(16, "Error", "$sourceArray is not a 2D array.")
	  Return
   EndIf

   ; Check if the specified row index is valid
   If $sourceRowIndex < 0 Or $sourceRowIndex >= UBound($sourceArray, 1) Then
	  MsgBox(16, "Error", "Invalid source row index.")
	  Return
   EndIf

   ; If $destinationArray is empty, initialize it with the first row from $sourceArray
   If UBound($destinationArray, 1) = 0 Then
	  ReDim $destinationArray[1][UBound($sourceArray, 2)]
	  For $j = 0 To UBound($sourceArray, 2) - 1
         $destinationArray[0][$j] = $sourceArray[$sourceRowIndex][$j]
	  Next
	  Return
   EndIf

   ; Check if the number of columns in $destinationArray and $sourceArray match
   If UBound($destinationArray, 2) <> UBound($sourceArray, 2) Then
	  MsgBox(16, "Error", "Number of columns in $destinationArray and $sourceArray must match.")
	  Return
   EndIf

   ; Add the specified row from $sourceArray to $destinationArray
   Global $newRowIndex = UBound($destinationArray, 1)
   Global $newRowSize = UBound($destinationArray, 2)

   ; Resize the destination array by creating a new array and copying values
   Global $tempArray[$newRowIndex + 1][$newRowSize]
   For $i = 0 To $newRowIndex - 1
	  For $j = 0 To $newRowSize - 1
		 $tempArray[$i][$j] = $destinationArray[$i][$j]
	  Next
   Next

   ; Copy values from the specified row of the source array to the new row in the destination array
   For $j = 0 To $newRowSize - 1
	  $tempArray[$newRowIndex][$j] = $sourceArray[$sourceRowIndex][$j]
   Next

   ; Assign the new array to the destination array
   $destinationArray = $tempArray
 EndFunc

Func ExportArrayToCSV($array, $filePath)
   Local $fileHandle = FileOpen($filePath, $FO_OVERWRITE + $FO_ANSI);$FO_UTF8)
   If $fileHandle = -1 Then
	  MsgBox(16, "Error", "Unable to open file for writing.")
	  Return
   EndIf

   For $i = 0 To UBound($array, 1) - 1
	  For $j = 0 To UBound($array, 2) - 1
		 FileWrite($fileHandle, $array[$i][$j])
		 If $j < UBound($array, 2) - 1 Then FileWrite($fileHandle, ',')
	  Next
	  FileWrite($fileHandle, @CRLF) ; Use FileWrite instead of FileWriteLine
   Next

   FileClose($fileHandle)
   ;MsgBox(64, "Success", "Array exported to CSV file: " & $filePath)
EndFunc

; Function to calculate and return the elapsed time as a formatted string
Func _GetElapsedTime($startTime, $format = 0)
   ; Get the elapsed time in milliseconds
   Local $elapsedTime = TimerDiff($startTime)

   ; Calculate hours, minutes, seconds, and milliseconds
   Local $hours = Int($elapsedTime / 3600000)
   Local $minutes = Int(Mod($elapsedTime, 3600000) / 60000)
   Local $seconds = Int(Mod($elapsedTime, 60000) / 1000)
   Local $milliseconds = Mod($elapsedTime, 1000)

   ; Format hours, minutes, and seconds with leading zeros if needed
   Local $formattedHours = StringFormat("%02d", $hours)
   Local $formattedMinutes = StringFormat("%02d", $minutes)
   Local $formattedSeconds = StringFormat("%02d", $seconds)
   Local $formattedMilliseconds = StringFormat("%03d", $milliseconds) ; Ensure milliseconds have 3 digits

   ; Format the elapsed time as a string
   Local $formattedTime
   If $format == 1 Then
        $formattedTime = $hours & " hours, " & _
                                  $minutes & " minutes, " & _
                                  $seconds & " seconds, and " & _
                                  $milliseconds & " milliseconds."
   Else
        $formattedTime = $formattedHours & ":" & _
                         $formattedMinutes & ":" & _
                         $formattedSeconds & "." & _
                         $formattedMilliseconds
   EndIf

   Return $formattedTime
EndFunc

Func _GetFileDirectory($filePath)
   ; Check if the file path contains a directory separator
   Local $separatorPos = StringInStr($filePath, "\", 0, -1)

   If $separatorPos Then
	  ; Extract the directory part using StringLeft
	  Return StringLeft($filePath, $separatorPos - 1)
   Else
	  ; If no separator is found, return an empty string or the original path
	  Return ""
   EndIf
EndFunc

Func _GetFileExtension($filePath)
   Local $ext = ""
   Local $dotPos = StringInStr($filePath, ".", 0, -1)
   If $dotPos > 0 Then
	  $ext = StringTrimLeft($filePath, $dotPos)
   EndIf
   Return $ext
EndFunc

Func _GetFileNameWithoutExtension($filePath)
   ; Extract the file name without extension using StringSplit
   Local $split = StringSplit($filePath, "\")
   Local $fileName = $split[$split[0]]

   ; Check if the file name contains a dot (.)
   Local $dotPos = StringInStr($fileName, ".", 0, -1)

   If $dotPos Then
	  ; If a dot is found, extract the substring before the dot
	  Return StringLeft($fileName, $dotPos - 1)
   Else
	  ; If no dot is found, return the original file name
	  Return $fileName
   EndIf
EndFunc
;;;;;;;;