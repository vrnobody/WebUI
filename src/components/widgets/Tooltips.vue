<script setup>
import { computed } from 'vue'
const props = defineProps(['css', 'tip'])

const css = computed({
    get() {
        const c = props.css
        const r = {}
        r[c] = true
        return r
    }
})

const tip = computed({
    get() {
        return props.tip
    }
})
</script>
<template>
    <div class="group inline-flex">
        <slot></slot>
        <pre
            class="invisible absolute z-50 inline-flex min-w-max shrink-0 items-center justify-center rounded border border-slate-400 bg-slate-200 px-2 py-0.5 text-sm duration-100 group-hover:visible dark:bg-slate-600"
            :class="css"
            >{{ tip }}</pre
        >
    </div>
</template>
<style scoped></style>
