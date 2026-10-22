<script setup>
import { ref } from 'vue'

const count = ref(0)
</script>

<template>
  <main class="page">
    <section class="card">
      <span class="eyebrow">Vue + AWS</span>
      <h1>Your app is ready to deploy.</h1>
      <p>
        This Vue application is built with Vite and served privately from Amazon
        S3 through CloudFront using an Origin Access Identity.
      </p>
      <button type="button" @click="count++">
        Clicked {{ count }} {{ count === 1 ? 'time' : 'times' }}
      </button>
    </section>
  </main>
</template>
