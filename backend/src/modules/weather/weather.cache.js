import NodeCache from "node-cache";

const weatherCache = new NodeCache({
  stdTTL: 600, // 10 minutes
  checkperiod: 120,
});

export default weatherCache;