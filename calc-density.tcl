source	~/Scripts/TCL/Tcl-Scripts/auto-ionz-IN.tcl
set	PO_tail_text "lipid and (name C22 to C29 C210 to C218 C32 to C39 C310 to C316)"
set	DM_tail_text "lipid and (name C22 to C29 C210 to C214 C32 to C39 C310 to C314)"
set     PC_head_text "lipid and (name O21 O22 O31 O32 O11 to O14 C1 C2 C21 C3 C31 C11 to C15 P N)"
set	prot_text    "protein and noh" 

puts	"To run this program type ~ iondensity <ofile> ~ or ~ popcdensity <ofile> ~ or ~ dmpcdensity <ofile>."

proc iondensity {ofile} {

	set	wat [atomselect top water]
	set	watend "_watden.dx"

	puts	-nonewline "Select anion by entering its name (chloride = CLA)"
	flush	stdout
	set	anion_name [gets stdin]
	set	cl [atomselect top "name $anion_name"]
	set	clend "_anden.dx"

	puts	-nonewline "Select cation by entering its name (potassium = POT, sodium = SOD)"
	flush	stdout
	set	cation_name [gets stdin]
	set	k [atomselect top "name $cation_name"]
	set	kend "_catden.dx"

	puts "Beginning water density calculation."

	volmap density $wat -allframes -combine avg -res 0.649 -o $ofile$watend

	puts "Finished water, starting chloride density calculation."

	volmap density $cl -allframes -combine avg -res 0.649 -o $ofile$clend

	puts "Finished chloride, starting potassium density calculation."

	volmap density $k -allframes -combine avg -res 0.649 -o $ofile$kend

	puts "Finished all calculations."
}

proc popcdensity {ofile} {

	global PC_head_text PO_tail_text

	set	lip_head [atomselect top $PC_head_text]
	set	lip_head_end "_lheadden.dx"

	set	lip_tail [atomselect top $PO_tail_text]
	set	lip_tail_end "_ltailden.dx"

	volmap density $lip_head -allframes -combine avg -res 0.649 -o $ofile$lip_head_end

	volmap density $lip_tail -allframes -combine avg -res 0.649 -o $ofile$lip_tail_end
}

proc dmpcdensity {ofile} {

        global PC_head_text DM_tail_text

        set     lip_head	[atomselect top $PC_head_text]
        set     lip_head_end	"_lheadden.dx"

        set     lip_tail	[atomselect top $DM_tail_text]
        set     lip_tail_end	"_ltailden.dx"

	set	lip_tot		[atomselect top lipids]
	set	lip_tot_end	"_ltotalden.dx"

#	volmap density $lip_head -allframes -combine avg -res 0.649 -o $ofile$lip_head_end

	volmap density $lip_tail -allframes -combine avg -res 0.649 -o $ofile$lip_tail_end
	
#	volmap density $lip_tot  -allframes -combine avg -res 0.649 -o $ofile$lip_tot_end
}

proc proteindensity {ofile} {

	global	prot_text

	set	protein [atomselect top $prot_text]
	set	prot_end "_protden.dx"

	volmap	density $protein -allframes -combine avg -res 0.649 -o $ofile$prot_end
}

proc autodmpc {in} {

	set     infile  [open $in r]

	set     inread  [read -nonewline $infile]

	set     inputs  [split $inread "\n"]

	close	$infile

	## The input file will contain the following: .psf/.pdb, .psf/.dcd, ofile
	##						   0	      1	      2
	
	set	m	0

	foreach line	$inputs {

		mol new		[lindex $line 0].psf

		mol addfile     [lindex $line 0].pdb

		mol new		[lindex $line 1].psf

		mol addfile     [lindex $line 1].dcd waitfor all

		align   $m [expr $m + 1]

		dmpcdensity	[lindex $line 2]

		mol 	delete	$m
		mol	delete	[expr $m + 1]

		set	m	[expr $m + 2]
	}
}
