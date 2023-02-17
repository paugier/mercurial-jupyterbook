import sys

from pathlib import Path
from dataclasses import dataclass
from pprint import pprint


@dataclass
class Cell:
    name: str or None
    commands: list

    def get_input_code(self):
        input_commands = [command[0] for command in self.commands]
        return "\n".join(input_commands)


def parse_test_file(path_test):

    full_code = path_test.read_text()

    cells_raw = full_code.split("#$ ")

    cells = []

    for cell_raw in cells_raw:

        if not cell_raw:
            continue

        first_line, remender = cell_raw.split("\n", 1)

        if first_line.startswith("name:"):
            cell_name = first_line.split("name:", 1)[1].strip()
            cell_raw = remender
        else:
            cell_name = None

        # print(cell_raw)
        # print(f"{cell_name = }")

        in_command = False
        command = ""
        output = ""
        commands = []

        for line in cell_raw.split("\n"):
            if line.startswith("  $ "):
                if in_command:
                    commands.append((command, output))
                    in_command = False

                command = line[4:]
                in_command = True
                output = ""
            elif line.startswith("  > "):
                command += "\n" + line[4:]
            elif in_command:
                output += line[2:]

        if in_command:
            commands.append((command, output))

        # print(commands)

        cells.append(Cell(cell_name, commands))

    return cells


if __name__ == "__main__":

    cells = parse_test_file(Path(sys.argv[-1]))
    pprint(cells)
