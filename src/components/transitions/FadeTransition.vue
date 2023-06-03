<script setup></script>

<template>
  <!-- wrap the built-in Transition component -->
  <Transition name="fade">
    <slot></slot>
    <!-- pass down slot content -->
  </Transition>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.6s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
