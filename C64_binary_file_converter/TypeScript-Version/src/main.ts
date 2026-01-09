import { PopulateOpCodeList } from "./opcode.js";
import { Convert } from "./convert.js";

export class C64BinaryToAssemblyConverter {

    startAddress: number = 0;
    populateOpCodeList: PopulateOpCodeList;
    fileContent: ArrayBuffer;
    code: any[];
    lineNumbers: number[];
    illegalOpcodes: any[];
    dataStatements: any[];
    result = null;

    constructor(element: HTMLElement) {
        element.innerHTML += `<div id="dropzone"><br>Drop your C64 files here<br><br></div>`;
    }

    public Init(): void {
        this.populateOpCodeList = new PopulateOpCodeList();
        this.populateOpCodeList.Init();
        let dropZone = document.getElementById('dropzone');
        dropZone.addEventListener('dragover', this.DragOverHandler);
        dropZone.addEventListener('drop', this.DropFileHandler);
    }

    public Run(): void {
        let val = sessionStorage.getItem("key");
        if (val != null) {
            const uint8Array = new Uint8Array([...val].map((c) => c.codePointAt(0)));
            console.log("Data Loaded!");
            this.ParseFile(uint8Array);
        }
        requestAnimationFrame(this.Run.bind(this));
    }

    public DropFileHandler(event): void {
        console.log("Dropped!");
        event.preventDefault();

        const dialog = <HTMLDialogElement>document.getElementById('dialog');
        const text = document.getElementById('text');

        let btn = document.createElement('button');
        document.body.appendChild(btn);
        btn.hidden = true;

        btn.addEventListener('click', (event) => {
            dialog.showModal();
        });

        dialog.addEventListener('cancel', (event) => {
            text.innerHTML += 'cancel event happened<br/>';
        });

        dialog.addEventListener('close', (event) => {
            text.innerHTML += 'close event happened<br/>';
        });

        btn.click();

        let file = event.dataTransfer.files[0], reader = new FileReader();
        reader.onload = function () {
            sessionStorage.clear();
            sessionStorage.setItem("name", file.name);
        };
        reader.onloadend = function () {
            sessionStorage.setItem("key", reader.result.toString());
            console.log("File Loaded !");
        }
        reader.readAsBinaryString(file);
        //reader.readAsArrayBuffer(file);
    }

    public DragOverHandler(ev) {
        console.log('File(s) in drop zone');
        ev.preventDefault();
    }

    private ParseFile(fileContent: any): void {
        let filePosition: number = 0;
        let lineNumber: number = 0;
        let pc: number = 0;

        this.lineNumbers = [];
        this.code = [];
        this.dataStatements = [];
        this.illegalOpcodes = [];

        let m_OpCodes = this.populateOpCodeList.GetOpCodes();

        while (filePosition < fileContent.length) {
            // Extract each 8 bit number from the array & convert to Hex
            let opCode = Convert.X2(fileContent[filePosition]);
            lineNumber = this.startAddress + filePosition;
            this.lineNumbers.push(lineNumber);
            let line: string = Convert.X4(this.startAddress + filePosition);

            line += "  " + opCode.toString();
            pc = this.startAddress + filePosition;

            let detail: any;
            for (let j = 0; j < m_OpCodes.length; j++) {
                if (m_OpCodes[j].m_code.toLowerCase() == opCode.toLowerCase()) {
                    detail = m_OpCodes[j].GetCode(line, filePosition, fileContent, lineNumber, pc, this.dataStatements, this.illegalOpcodes);
                    j = m_OpCodes.length - 1;
                }
            }
            filePosition = detail.filePosition;
            this.dataStatements = detail.dataStatements;
            this.illegalOpcodes = detail.illegalOpcodes;
            this.code.push(detail.line);
        }

        let el = document.getElementById('parseOutput');
        el.innerHTML = this.code.join("<br />");

        sessionStorage.clear();
    }
}