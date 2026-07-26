from pathlib import Path
import subprocess
import kagglehub

git_root : str = Path(
    subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"],
        text=True
    ).strip()
)

dataset_dir : str = git_root / "dbt/ecommerce_datahub/seeds"

# Download Kaggle data
# https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data
path = kagglehub.dataset_download(
    "olistbr/brazilian-ecommerce",
    output_dir=dataset_dir
)

print("Path to dataset files:", path)

# # Remove the UTF-8 BOM from the category translation file.
# # The first header contains a hidden character:
# # '\ufeffproduct_category_name,product_category_name_english'
# translation_file = dataset_dir / "product_category_name_translation.csv"
#
# content = translation_file.read_text(encoding="utf-8-sig")
# translation_file.write_text(content, encoding="utf-8")
#
# print(f"Removed UTF-8 BOM from {translation_file.name}")
# with open(translation_file, "r", encoding="utf-8") as f:
#     print(repr(f.readline()))