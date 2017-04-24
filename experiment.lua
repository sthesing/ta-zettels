yaml = require("yamlminusone")

example_data = yaml.loadfile("example-data.yaml")

yaml.dumpfile(example_data, "example-data-output.yaml")