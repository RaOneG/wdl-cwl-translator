version 1.0

# Source: https://github.com/biowdl/tasks/blob/develop/bcftools.wdl
#
# Copyright (c) 2018 Leiden University Medical Center
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

task Stats {
    input {
        File inputVcf
        File inputVcfIndex
        String outputPath = basename(inputVcf) + ".stats"
        Boolean firstAlleleOnly = false
        Boolean splitByID = false
        Array[String] samples = []
        Boolean verbose = false

        File? compareVcf
        File? compareVcfIndex
        String? afBins
        String? afTag
        String? collapse
        String? depth
        String? exclude
        File? exons
        String? applyFilters
        File? fastaRef
        File? fastaRefIndex
        String? include
        String? regions
        File? regionsFile
        File? samplesFile
        String? targets
        File? targetsFile
        String? userTsTv

        Int threads = 0
        String memory = "256M"
        # Int timeMinutes = 1 + 2* ceil(size(select_all([inputVcf, compareVcf]), "G")) # TODO: Estimate, 2 minutes per GB, refine later.
        String dockerImage = "quay.io/biocontainers/bcftools:1.10.2--h4f4756c_2"
    }

    command {
        set -e
        mkdir -p $(dirname ~{outputPath})
        bcftools stats \
        ~{"--af-bins " + afBins} \
        ~{"--af-tag " + afTag} \
        ~{true="--1st-allele-only" false="" firstAlleleOnly} \
        ~{"--collapse " + collapse} \
        ~{"--depth " + depth} \
        ~{"--exclude " + exclude} \
        ~{"--exons " + exons} \
        ~{"--apply-filters " + applyFilters} \
        ~{"--fasta-ref " + fastaRef} \
        ~{"--include " + include} \
        ~{true="--split-by-ID" false="" splitByID} \
        ~{"--regions " + regions} \
        ~{"--regions-file " + regionsFile} \
        ~{true="--samples" false="" length(samples) > 0} ~{sep="," samples} \
        ~{"--samples-file " + samplesFile} \
        ~{"--targets " + targets} \
        ~{"--targets-file " + targetsFile} \
        ~{"--user-tstv " + userTsTv} \
        --threads ~{threads} \
        ~{true="--verbose" false="" verbose} \
        ~{inputVcf} ~{compareVcf} > ~{outputPath}
    }

    output {
        File stats = outputPath
    }

    runtime {
        cpu: threads + 1
        memory: memory
        # time_minutes: timeMinutes
        docker: dockerImage
    }

    parameter_meta {
        # inputs
        inputVcf: {description: "The VCF to be analysed.", category: "required"}
        inputVcfIndex: {description: "The index for the input VCF.", category: "required"}
        outputPath: {description: "The location the output VCF file should be written.", category: "common"}
        firstAlleleOnly: {description: "Include only 1st allele at multiallelic sites.", category: "advanced"}
        splitByID: {description: "Collect stats for sites with ID separately (known vs novel).", category: "advanced"}
        samples: {description: "List of samples for sample stats, \"-\" to include all samples.", category: "advanced"}
        verbose: {description: "Produce verbose per-site and per-sample output.", category: "advanced"}
        compareVcf: {description: "When inputVcf and compareVCF are given, the program generates separate stats for intersection and the complements. By default only sites are compared, samples must be given to include also sample columns.", category: "common"}
        compareVcfIndex: {description: "Index for the compareVcf.", category: "common"}
        afBins: {description: "Allele frequency bins, a list (0.1,0.5,1) or a file (0.1\n0.5\n1).", category: "advanced"}
        afTag: {description: "Allele frequency tag to use, by default estimated from AN,AC or GT.", category: "advanded"}
        collapse: {description: "Treat as identical records with <snps|indels|both|all|some|none>, see man page for details.", category: "advanced"}
        depth: {description: "Depth distribution: min,max,bin size [0,500,1].", category: "advanced"}
        exclude: {description: "Exclude sites for which the expression is true (see man page for details).", category: "advanced"}
        exons: {description: "Tab-delimited file with exons for indel frameshifts (chr,from,to; 1-based, inclusive, bgzip compressed).", category: "advanced"}
        applyFilters: {description: "Require at least one of the listed FILTER strings (e.g. \"PASS,.\").", category: "advanced"}
        fastaRef: {description: "Faidx indexed reference sequence file to determine INDEL context.", category: "advanced"}
        fastaRefIndex: {description: "Index file (.fai) for fastaRef. Must be supplied if fastaRef is supplied.", category: "advanced"}
        include: {description: "Select sites for which the expression is true (see man page for details).", category: "advanced"}
        regions: {description: "Restrict to comma-separated list of regions.", category: "advanced"}
        regionsFile: {description: "Restrict to regions listed in a file.", category: "advanced"}
        samplesFile: {description: "File of samples to include.", category: "advanced"}
        targets: {description: "Similar to regions but streams rather than index-jumps.", category: "advanced"}
        targetsFile: {description: "Similar to regionsFile but streams rather than index-jumps.", category: "advanced"}
        userTsTv: {description: "<TAG[:min:max:n]>. Collect Ts/Tv stats for any tag using the given binning [0:1:100].", category: "advanced"}
        threads: {description: "Number of extra decompression threads [0].", category: "advanced"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.", category: "advanced"}

        # outputs
        stats: {description: "Text file stats which is suitable for machine processing and can be plotted using plot-vcfstats."}
    }
}