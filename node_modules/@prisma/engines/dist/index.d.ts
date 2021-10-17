import { BinaryType } from '@prisma/fetch-engine';
export declare function getEnginesPath(): string;
export declare const DEFAULT_CLI_QUERY_ENGINE_BINARY_TYPE = BinaryType.libqueryEngine;
/**
 * Checks if the env override `PRISMA_CLI_QUERY_ENGINE_TYPE` is set to `library` or `binary`
 * Otherwise returns the default
 */
export declare function getCliQueryEngineBinaryType(): BinaryType.libqueryEngine | BinaryType.queryEngine;
export declare function ensureBinariesExist(): Promise<void>;
export { enginesVersion } from '@prisma/engines-version';
