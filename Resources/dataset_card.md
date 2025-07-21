# Dataset Card: Edu-Tutor Dataset

## Description
This dataset includes educational prompts and answers for fine-tuning large language models into tutors. Domains include:
- General Science (ScienceQA DATASET)
- Basic Math (MATHQA DATASET)
- History
- English Grammar 

## Format
- JSONL format
- Fields: `instruction`, `input`, `output`

## License
MIT License (or specify CC BY-SA if applicable)

## Used For
Fine-tuning `Gemma-3N-34B` with `sloth-finetuning`.
