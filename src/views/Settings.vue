<script setup>
import utils from '@/misc/utils.js'
import { onMounted, ref } from 'vue'

const t = utils.getTranslator()

const settings = ref({})
const isRequireRerender = ref(false)

const propsTable = {
    maxConcurrentV2RayCoreNum: 'maxConcurrentCore',
    isEnableUtlsFingerprint: 'enableUTlsfingerprint',
    uTlsFingerprint: 'uTlsFingerprint',
    isUseCustomUserAgent: 'enableUserAgent',
    CustomUserAgent: 'userAgent',
    isUseCustomSpeedtestSettings: 'enableSpeedtestSettings',
    CustomSpeedtestUrl: 'speedtestUrl',
    CustomSpeedtestTimeout: 'speedtestTimeout',
    CustomSpeedtestExpectedSizeInKib: 'speedtestSize',
    CustomSpeedtestCycles: 'speettestCycles',
    QuickSwitchServerLantency: 'quickSwitchLatency',
    CustomDefImportTrojanShareLink: 'importTrojan',
    CustomDefImportSsShareLink: 'importShadowsocks',
    DefaultCoreName: 'coreName',
    DefaultInboundName: 'inbName',
    CustomDefImportHost: 'importIp',
    CustomDefImportPort: 'importPort'
}

const optionsTable = {}

const areasTable = {
    CustomDefInbounds: 'h-[12rem]'
}

function saveSettings() {
    const props = settings.value
    const next = function (ok) {
        if (ok) {
            loadSettings()
            Swal.fire(t('success'))
        } else {
            Swal.file(t('failed'))
        }
    }
    utils.call(next, 'SetUserSettings', [props])
}

function loadSettings() {
    const names = Object.keys(propsTable)
    const next = function (str) {
        try {
            settings.value = JSON.parse(str)
            forceRerender()
        } catch (err) {
            Swal.fire(err.toString())
        }
    }
    utils.call(next, 'GetUserSettings', [names])
}

function getElementType(key) {
    const s = settings.value
    if (!Object.getOwnPropertyDescriptor(s, key)) {
        return null
    }
    const t = typeof s[key]
    switch (t) {
        case 'boolean':
            return 'checkbox'
        case 'number':
            if (Object.getOwnPropertyDescriptor(optionsTable, key)) {
                return 'select'
            }
            return 'text'
        case 'string':
            if (Object.getOwnPropertyDescriptor(areasTable, key)) {
                return 'textarea'
            }
            return 'text'
        default:
            break
    }
    return 'span'
}

const forceRerender = () => {
    isRequireRerender.value = !isRequireRerender.value
}

onMounted(() => {
    loadSettings()
})
</script>

<template>
    <!-- toolstrip -->
    <div
        class="justify-left fixed left-8 top-0 z-20 flex h-12 grow items-center px-4 py-0 md:left-56"
    >
        <div class="m-0 text-2xl">
            <button @click="saveSettings" class="mx-1 my-0">
                <i class="fas fa-save"></i> {{ t('save') }}
            </button>
        </div>
    </div>

    <!-- header -->
    <div class="fixed left-0 right-0 top-12 z-10 flex grow md:left-56">
        <div
            class="table h-6 grow bg-slate-400 text-xs text-neutral-600 dark:bg-slate-500 dark:text-neutral-700"
        >
            <div class="table-cell w-[18rem] px-1 py-0 text-center align-middle">
                {{ t('key') }}
            </div>
            <div class="table-cell px-1 py-0 text-center align-middle">{{ t('value') }}</div>
        </div>
    </div>

    <!-- settings list -->
    <div class="dark:text-neutral-100">
        <div class="block h-6 w-full"></div>
        <ul :key="isRequireRerender">
            <li
                v-for="(value, key) in propsTable"
                :key="key"
                class="flex items-start py-1 odd:bg-neutral-200 dark:odd:bg-slate-600"
            >
                <div class="inline-flex w-[18rem] shrink-0 px-1">{{ t(value) }}</div>
                <div class="inline-flex grow px-1">
                    <input
                        v-if="getElementType(key) === 'text'"
                        type="text"
                        v-model="settings[key]"
                        class="grow border border-neutral-400 bg-neutral-100 px-1 dark:border-0 dark:bg-slate-500"
                    />
                    <input
                        v-if="getElementType(key) === 'checkbox'"
                        type="checkbox"
                        v-model="settings[key]"
                        class="mt-1 h-4 w-4"
                    />
                    <select
                        v-if="getElementType(key) === 'select'"
                        v-model="settings[key]"
                        class="grow border border-neutral-400 bg-neutral-200 px-1 dark:border-0 dark:bg-slate-600"
                    >
                        <option v-for="(ov, idx) in optionsTable[key]" :key="idx" :value="idx">
                            {{ ov }}
                        </option>
                    </select>
                    <textarea
                        v-if="getElementType(key) === 'textarea'"
                        v-model="settings[key]"
                        :class="{ [areasTable[key]]: true }"
                        class="grow border border-neutral-400 bg-neutral-100 px-1 dark:border-0 dark:bg-slate-500"
                    ></textarea>
                    <span v-if="getElementType(key) === 'span'">{{ settings[key] }}</span>
                </div>
            </li>
        </ul>
        <div class="block h-10 grow"></div>
    </div>
</template>

<style scoped></style>
