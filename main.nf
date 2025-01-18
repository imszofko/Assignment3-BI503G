#!/usr/bin/env nextflow

// 1.b and call a process that iterates over the FASTA sequences
//If the GC content is greater than the cutoff provided as input
//then the header and sequence should be written to an output file called output.txt
//the output should be emitted in he process output channel

process calcGCContent {
    input:
    path fastaFile
    val cutoff

    output:
    path 'output.txt'

    script:
    """
    #!/usr/bin/env python3

import sys
import Bio
from Bio import SeqIO

##Inputs and the output file and the cutoff, they are in literal string as it would not write it to the file otherwise because of the way that they output is written to the file in literal string
##Not exactly sure why, but doing this fixed it.
inputFile = f"$fastaFile"
outputFile = "output.txt"
cutoff = float(f"${cutoff}") #Float value

##I tried to do it with the fasta file being open and then writing to the output file if the
##GCContent was over the cutoff, but there was issues with integer and float objects being not iterable, and such 
with open(inputFile, "r") as inFile:
    with open(outputFile, "w") as outFile:
        for record in SeqIO.parse(inFile, "fasta"):
            ##Sequence
            seq = record.seq          
            ##Calculating GC Content
            gcContent = (seq.count('G') + seq.count('C')) / len(seq)
            if gcContent > cutoff:
                #If the gcContent is greater than the value cutoff input, it writes it to the outputF
                outFile.write(f">{record.id}\\n")
                outFile.write(f"{str(seq)}\\n")
    """
}

workflow  {
    //1.a Defines the parameters of inputFile and cutoff
    //1.b Should create a path channel to the input FASTA file
    //Create a channel for the input FASTA file
    fastaChannel = Channel.fromPath(params.inputFile)
    cutoffChannel = Channel.of(params.cutoff)

    // Does the work
    calcGCContent(fastaChannel, cutoffChannel)        
}
