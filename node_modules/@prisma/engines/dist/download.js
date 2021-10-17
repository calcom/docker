"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const debug_1 = __importDefault(require("@prisma/debug"));
const engines_version_1 = require("@prisma/engines-version");
const fetch_engine_1 = require("@prisma/fetch-engine");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const _1 = require(".");
const debug = (0, debug_1.default)('prisma:download');
const binaryDir = path_1.default.join(__dirname, '../');
const lockFile = path_1.default.join(binaryDir, 'download-lock');
let createdLockFile = false;
async function main() {
    if (fs_1.default.existsSync(lockFile) &&
        parseInt(fs_1.default.readFileSync(lockFile, 'utf-8'), 10) > Date.now() - 20000) {
        debug(`Lock file already exists, so we're skipping the download of the prisma binaries`);
    }
    else {
        createLockFile();
        let binaryTargets = undefined;
        if (process.env.PRISMA_CLI_BINARY_TARGETS) {
            binaryTargets = process.env.PRISMA_CLI_BINARY_TARGETS.split(',');
        }
        const cliQueryEngineBinaryType = (0, _1.getCliQueryEngineBinaryType)();
        const binaries = {
            [cliQueryEngineBinaryType]: binaryDir,
            [fetch_engine_1.BinaryType.migrationEngine]: binaryDir,
            [fetch_engine_1.BinaryType.introspectionEngine]: binaryDir,
            [fetch_engine_1.BinaryType.prismaFmt]: binaryDir,
        };
        await (0, fetch_engine_1.download)({
            binaries,
            showProgress: true,
            version: engines_version_1.enginesVersion,
            failSilent: true,
            binaryTargets,
        }).catch((e) => debug(e));
        cleanupLockFile();
    }
}
function createLockFile() {
    createdLockFile = true;
    fs_1.default.writeFileSync(lockFile, Date.now().toString());
}
function cleanupLockFile() {
    if (createdLockFile) {
        try {
            if (fs_1.default.existsSync(lockFile)) {
                fs_1.default.unlinkSync(lockFile);
            }
        }
        catch (e) {
            debug(e);
        }
    }
}
main().catch((e) => debug(e));
// if we are in a Now context, ensure that `prisma generate` is in the postinstall hook
process.on('beforeExit', () => {
    cleanupLockFile();
});
process.once('SIGINT', () => {
    cleanupLockFile();
    process.exit();
});
//# sourceMappingURL=download.js.map