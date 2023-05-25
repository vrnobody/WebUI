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
        <div class="min-w-max dark:bg-slate-600 bg-slate-200 border border-slate-400 inline-flex justify-center items-center shrink-0 px-2 py-0.5 rounded z-50 text-sm duration-100 absolute invisible group-hover:visible"
            :class="css">
            {{ tip }}
        </div>
    </div>
</template>
<style scoped></style>