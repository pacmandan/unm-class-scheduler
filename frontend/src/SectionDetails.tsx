import { Section } from './catalog'

const SectionDetails = ({section}: {section: Section}) => {
  return (<>
    <div className='text-3xl'>{section.subject.code} {section.course.number} - {section.course.title}</div>
    <div className='whitespace-pre-wrap'>{section.course.catalog_description}</div>
  </>)
}

export default SectionDetails;