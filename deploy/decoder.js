function decodeComplexData(encodedData) {
    const decodedData = encodedData.map(item => {
        if (Array.isArray(item)) {
            return item.map(innerItem => atob(innerItem));
        } else if (typeof item === 'object' && item !== null && item.hasOwnProperty('value')) {
            return parseInt(item.value);
        } else if (typeof item === 'object' && item !== null && item.hasOwnProperty('avatarMetadata')) {
            return {
                avatarMetadata: atob(item.avatarMetadata),
                itemMetadata: item.itemMetadata.map(innerItem => atob(innerItem)),
                x: parseInt(item.x.value),
                y: parseInt(item.y.value),
                z: parseInt(item.z.value),
                maxUserScore: parseInt(item.maxUserScore.value),
                friends: item.friends.map(innerItem => atob(innerItem))
            };
        } else {
            return atob(item);
        }
    });

    return decodedData;
}

// Example usage
const encodedComplexData = [
  'eyJuYW1lIjogIkFyYm9yZyIsICJkZXNjcmlwdGlvbiI6ICJBVkFUQVIiLCAiaW1hZ2UiOiAiUWtsVVV6b2dhSFIwY0hNNkx5OW5hWFJvZFdJdVkyOXRMMkZ5WW05eVp5OXRZWE4wWlhJdWNHaHciLCAiYXR0cmlidXRlcyI6ICJBVkFUQVIifQ==',
  [],
  { value: "18" },
  { value: "25" },
  { value: "30" },
  { value: "1000" },
  [
    '0x0000000000000000000000000000000000000000',
    '0x0000000000000000000000000000000000000000',
    '0x0000000000000000000000000000000000000000',
    '0x0000000000000000000000000000000000000000'
  ],
  {
    avatarMetadata: 'eyJuYW1lIjogIkFyYm9yZyIsICJkZXNjcmlwdGlvbiI6ICJBVkFUQVIiLCAiaW1hZ2UiOiAiUWtsVVV6b2dhSFIwY0hNNkx5OW5hWFJvZFdJdVkyOXRMMkZ5WW05eVp5OXRZWE4wWlhJdWNHaHciLCAiYXR0cmlidXRlcyI6ICJBVkFUQVIifQ==',
    itemMetadata: [],
    x: { value: "18" },
    y: { value: "25" },
    z: { value: "30" },
    maxUserScore: { value: "1000" },
    friends: [
      '0x0000000000000000000000000000000000000000',
      '0x0000000000000000000000000000000000000000',
      '0x0000000000000000000000000000000000000000',
      '0x0000000000000000000000000000000000000000'
    ]
  }
];

const decodedComplexData = decodeComplexData(encodedComplexData);

console.log(decodedComplexData);
