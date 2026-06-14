# Step 1. Index a VCF file

```bash
$ tabix CEU.exon.2010_03.genotypes.vcf.gz

```


# Answers to questions from "Genomic Variant Files"

Q1: How many positions are found in this region (1:1105411-44137860) in the VCF file?

A: 69 positions are found:

```bash
$ tabix CEU.exon.2010_03.genotypes.vcf.gz 1:1105411-44137860 | wc -l

# 69
```

Q2: How many samples are included in the VCF file?

A: 90 samples are included in the file:

```bash
$ bcftools query -l CEU.exon.2010_03.genotypes.vcf.gz | wc -l
 
#[W::bcf_hdr_check_sanity] AC should be declared as Number=A
# The warning regarding is due to outdated metadata in the VCF header. It does not affect data integrity or the accuracy of the analysis
# 90
```

Q3: How many positions are there total in the VCF file?

A: 3489 positions in total

```bash
$ bcftools query -f '%POS\n' CEU.exon.2010_03.genotypes.vcf.gz | wc -l

# [W::bcf_hdr_check_sanity] AC should be declared as Number=A 
# The warning regarding is due to outdated metadata in the VCF header. It does not affect data integrity or the accuracy of the analysis
# 3489
```

Q4: How many positions are there with AC=1? 
Note that you cannot simply count lines since the output of bcftools filter includes the VCF header lines. 
You will need to use bcftools query to get this number.
A: 1075 positions with AC=1. Those singletons mean that the mutations are unique (have only 1 allele) and the genetic variance is rather high among samples.
First explore some data. Here column -t is used for nice output table with first 10 results:

```bash
$ bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%AC\n' -i 'AC=1' CEU.exon.2010_03.genotypes.vcf.gz | head -n 10 | column -t

# [W::bcf_hdr_check_sanity] AC should be declared as Number=A
# 1  1105411   G  A  1
# 1  1110240   T  A  1
# 1  3541597   C  T  1
# 1  3545211   G  A  1
# 1  7760783   A  G  1
# 1  10424956  A  G  1
# 1  17801259  G  C  1
# 1  17822149  C  T  1
# 1  17886690  C  T  1
# 1  18022150  C  T  1
```
then count the results:
```
$ bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' -i 'AC=1' CEU.exon.2010_03.genotypes.vcf.gz | wc -l
# [W::bcf_hdr_check_sanity] AC should be declared as Number=A
# 1075

```
Q5: What is the ratio of transitions to transversions (ts/tv) in this file?
A: 3.47
```bash
$ bcftools stats CEU.exon.2010_03.genotypes.vcf.gz > vcf_report.txt
```

Note: The QUAL field in the statistics report is marked as missing ('.'). This reflects the metadata structure of the VCF file, where quality is reported at the individual genotype level.
Visualization of some metrics (The files - scripts and plots in `vcf_plots` are generated automatically) via this command:

```bash
$ plot-vcfstats -p vcf_plots/ vcf_report.txt
```

The dataset is characterized by a predominance of G>A and C>T substitutions.

![Frequency of substitutions](vcf_plots/substitutions.0.png)


