// The key-feature pages (/features/<slug>), level 2 of the site hierarchy in
// locapp-23 docs/marketing/website/site-hierarchy.md. Each claim cites the
// feed IDs it rests on (public-features.json: done and Public stories only);
// `ids` lists the sub-features, rendered with their feed titles and benefit
// lines, so they can never say more than the feed does.

export interface Shot {
  kind: 'phone' | 'card' | 'lock';
  src?: string;
  alt?: string;
  // For a phone in a panel: which end of the screen carries the point.
  peek?: 'top' | 'bottom';
  show?: number;
}

export interface FeaturePage {
  slug: string;
  audience: 'vendors' | 'customers';
  name: string;
  headline: string;
  line: string;
  description: string;
  bullets: { text: string; ids: string[] }[];
  hero: { front: Shot; back: Shot };
  panel: Shot;
  ids: string[];
}

const img = (f: string) => `/images/app/${f}.webp`;

export const featurePages: FeaturePage[] = [
  {
    slug: 'free-listing',
    audience: 'vendors',
    name: 'Free listing',
    // VRG-001, VRG-007
    headline: 'Free to be found',
    line: 'Put your van or shop on the Chimes map in minutes. It costs nothing.',
    description:
      'Put your ice cream van or shop on the Chimes map for free: what you sell, your town and your links. Sign up on iPhone with your email and a code.',
    bullets: [
      { text: 'A pin in your area with what you sell and how to reach you.', ids: ['VRG-007', 'VMN-011', 'VMN-012', 'MAP-012'] },
      { text: 'Sign up with your email and a code. No password.', ids: ['VRG-001', 'VRG-008', 'VRG-010'] },
      { text: 'Closed for the day? Hide your listing with one tap.', ids: ['VLT-007a'] },
    ],
    hero: {
      front: { kind: 'phone', src: img('20-register-business'), alt: 'Register your business: Free listing or Live van tracking' },
      back: { kind: 'phone', src: img('15-first-launch-map'), alt: 'The Chimes map of England with ice cream vans and shops grouped by area' },
    },
    panel: {
      kind: 'phone',
      src: img('16-favourite-vendor-card'),
      alt: "A listing's card on the Chimes map: Mr Frosty's, mobile caterer, Isle of Wight",
      peek: 'bottom',
      show: 0.55,
    },
    ids: ['VRG-001', 'VRG-007', 'VMN-011', 'VMN-012', 'MAP-002', 'MAP-012', 'VLT-007a', 'VRG-008', 'VRG-010', 'VDM-002'],
  },
  {
    slug: 'live-van-tracking',
    audience: 'vendors',
    name: 'Live van tracking',
    // MAP-003
    headline: 'Customers watch your van come down the road',
    // VDM-001, VDM-005: every live-tracking vendor starts in demo mode (about hourly).
    line: "Start free in demo mode, then go fully live: your van moves on customers' maps and they get a chime as you arrive.",
    description:
      'Live van tracking for ice cream vans: share your location from your iPhone and customers see your van move on the Chimes map and get an alert when you arrive.',
    bullets: [
      { text: 'Tap Share Location, lock your phone and drive.', ids: ['VLT-004', 'VBG-001'] },
      { text: 'Customers in the area get one chime as you arrive.', ids: ['ALR-006', 'ALR-007'] },
      // Not "off the map": an Offline van can still show, faded, with an OFFLINE card (MAP-013).
      { text: 'Tap Stop Sharing and customers stop seeing where you are. Other vans never see you.', ids: ['VLT-003', 'VBG-002', 'ALR-008', 'ALR-014'] },
    ],
    hero: {
      front: { kind: 'card', src: img('21-location-sharing-live-card'), alt: "Chimes Location Sharing: You're Live, with a Stop Sharing button" },
      back: { kind: 'phone', src: img('02-vendor-card'), alt: "Michele's Ices on the Chimes map, Live, with Navigate, WhatsApp and Call buttons" },
    },
    panel: { kind: 'card', src: img('22-location-sharing-offline-card'), alt: "Chimes Location Sharing: You're Offline, van not visible to your customers" },
    ids: ['VRG-002', 'VDM-001', 'VDM-005', 'VDM-003', 'VLT-001', 'VLT-004', 'VLT-003', 'VBG-001', 'VBG-002', 'VBG-006', 'MAP-003', 'MAP-004', 'MAP-011', 'ALR-008', 'ALR-014'],
  },
  {
    slug: 'alerts',
    audience: 'customers',
    name: 'Alerts',
    // ALR-006
    headline: 'Know the moment the van comes into your area',
    line: 'Pick your area once. Chimes tells you when an ice cream van arrives, even with the app closed.',
    description:
      'Chimes alerts you when an ice cream van comes into your area: pick a postcode and radius, and the Chimes tune and the van’s name arrive on your phone. iPhone and Android.',
    bullets: [
      { text: 'Choose your area by postcode and radius, and see it on the map.', ids: ['ALR-001', 'ALR-003'] },
      { text: "The Chimes tune and the van's name on your phone, app open or not.", ids: ['ALR-009', 'ALR-010'] },
      { text: 'One alert per visit, and only for vans really out trading.', ids: ['ALR-007', 'ALR-008'] },
    ],
    hero: {
      front: { kind: 'lock' },
      back: { kind: 'phone', src: img('01-map-geofence'), alt: 'The Chimes map with a blue circle around the Isle of Wight' },
    },
    panel: {
      kind: 'phone',
      src: img('11-onboarding-notifications'),
      alt: 'Chimes asks to send notifications, showing an alert from Michele’s Ices',
      peek: 'top',
      show: 0.5,
    },
    ids: ['ALR-001', 'ALR-003', 'ALR-006', 'ALR-007', 'ALR-008', 'ALR-009', 'ALR-010', 'SMN-002', 'SMN-003', 'SMN-004', 'CUS-001', 'CUS-013a'],
  },
  {
    slug: 'map',
    audience: 'customers',
    name: 'The map',
    // MAP-001
    headline: 'Ice cream vans and shops near you',
    line: "Live vans show where they are now. Shops and vans not on Chimes yet are there too.",
    description:
      'The Chimes map shows ice cream vans and shops near you, with live vans where they are now. Tap one for what they sell and how to reach them.',
    bullets: [
      { text: 'Live vans show where they are now, with their own picture.', ids: ['MAP-003', 'MAP-004'] },
      { text: 'Tap a van or shop for what they sell and how to reach them.', ids: ['MAP-010', 'MAP-011', 'MAP-012', 'VMN-012'] },
      { text: 'Filter to Chimes vendors, live vans or your favourites.', ids: ['MAP-015'] },
    ],
    hero: {
      front: { kind: 'phone', src: img('13-vendor-filter'), alt: 'The Chimes map filter: All, Chimes, Tracked, Live, Favourites' },
      back: { kind: 'phone', src: img('15-first-launch-map'), alt: 'The Chimes map of England with ice cream vans and shops grouped by area' },
    },
    panel: {
      kind: 'phone',
      src: img('02-vendor-card'),
      alt: "Michele's Ices on the Chimes map, Live, with Navigate, WhatsApp and Call buttons",
      peek: 'bottom',
      show: 0.55,
    },
    ids: ['MAP-001', 'MAP-002', 'MAP-003', 'MAP-004', 'MAP-010', 'MAP-011', 'MAP-012', 'VMN-012', 'MAP-013', 'MAP-015'],
  },
  {
    slug: 'favourites',
    audience: 'customers',
    name: 'Favourites',
    // FAV-001, FAV-009
    headline: 'Your favourite vans, one tap away',
    line: 'Heart the vans and shops you love and see which are out now.',
    description:
      'Save your favourite ice cream vans and shops in Chimes and see at a glance which are out now. Free on iPhone, iPad and Android.',
    bullets: [
      { text: 'Tap the heart on any van or shop to save it.', ids: ['FAV-001', 'FAV-004'] },
      { text: 'See which favourites are out now, and when the others were last seen.', ids: ['FAV-007', 'FAV-009'] },
      { text: 'Favourites wear a small heart on the map.', ids: ['FAV-015'] },
    ],
    hero: {
      front: { kind: 'phone', src: img('18-favourites-map'), alt: 'Favourite vans and shops with small hearts on the Chimes map' },
      back: { kind: 'phone', src: img('16-favourite-vendor-card'), alt: "Mr Frosty's card on the Chimes map, with a filled heart" },
    },
    panel: {
      kind: 'phone',
      src: img('17-favourites-list'),
      alt: 'The Chimes favourites list, with Gelato Dreams Live',
      peek: 'bottom',
      show: 0.5,
    },
    ids: ['FAV-001', 'FAV-002', 'FAV-004', 'FAV-007', 'FAV-009', 'FAV-011', 'FAV-013', 'FAV-015'],
  },
];

export const pageFor = (id: string) => featurePages.find((p) => p.ids.includes(id));
